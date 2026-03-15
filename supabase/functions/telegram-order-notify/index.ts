import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

type OrderWebhookPayload = {
  type?: string;
  table?: string;
  schema?: string;
  record?: {
    id?: string;
  };
};

type OrderRow = {
  id: string;
  customer_name: string;
  phone: string;
  address: string;
  status: string;
  created_at: string;
  order_items: Array<{
    quantity: number;
    unit_price: number;
    products: { name: string } | Array<{ name: string }> | null;
  }>;
};

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const telegramBotToken = Deno.env.get('TELEGRAM_BOT_TOKEN') ?? '';
const telegramChatId = Deno.env.get('TELEGRAM_CHAT_ID') ?? '';
const webhookSecret = Deno.env.get('TELEGRAM_WEBHOOK_SECRET') ?? '';

const admin = createClient(supabaseUrl, serviceRoleKey);

Deno.serve(async (request) => {
  if (request.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405);
  }

  if (!supabaseUrl || !serviceRoleKey || !telegramBotToken || !telegramChatId) {
    return jsonResponse(
      { error: 'Missing required function secrets.' },
      500,
    );
  }

  if (webhookSecret) {
    const incomingSecret = request.headers.get('x-webhook-secret');
    if (incomingSecret != webhookSecret) {
      return jsonResponse({ error: 'Unauthorized webhook.' }, 401);
    }
  }

  const payload = (await request.json()) as OrderWebhookPayload;
  const orderId = payload.record?.id;

  if (!orderId) {
    return jsonResponse({ ok: true, skipped: 'No order id found.' });
  }

  const order = await fetchOrderWithItems(orderId);
  if (!order) {
    return jsonResponse({ error: 'Order not found.' }, 404);
  }

  const message = buildTelegramMessage(order);

  const telegramResponse = await fetch(
    `https://api.telegram.org/bot${telegramBotToken}/sendMessage`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        chat_id: telegramChatId,
        text: message,
        parse_mode: 'HTML',
        disable_web_page_preview: true,
      }),
    },
  );

  if (!telegramResponse.ok) {
    const telegramError = await telegramResponse.text();
    console.error('Telegram API error:', telegramError);
    return jsonResponse({ error: 'Telegram API request failed.' }, 502);
  }

  return jsonResponse({ ok: true });
});

async function fetchOrderWithItems(orderId: string): Promise<OrderRow | null> {
  for (let attempt = 0; attempt < 5; attempt += 1) {
    const { data, error } = await admin
      .from('orders')
      .select(
        `
          id,
          customer_name,
          phone,
          address,
          status,
          created_at,
          order_items (
            quantity,
            unit_price,
            products (
              name
            )
          )
        `,
      )
      .eq('id', orderId)
      .single();

    if (error) {
      console.error('Supabase fetch error:', error.message);
      return null;
    }

    const order = data as OrderRow;

    if (order.order_items.length > 0) {
      return order;
    }

    await delay(350);
  }

  const { data, error } = await admin
    .from('orders')
    .select(
      `
        id,
        customer_name,
        phone,
        address,
        status,
        created_at,
        order_items (
          quantity,
          unit_price,
          products (
            name
          )
        )
      `,
    )
    .eq('id', orderId)
    .single();

  if (error) {
    console.error('Supabase fetch error:', error.message);
    return null;
  }

  return data as OrderRow;
}

function buildTelegramMessage(order: OrderRow): string {
  const orderDate = new Date(order.created_at).toLocaleString('en-US', {
    dateStyle: 'medium',
    timeStyle: 'short',
  });

  const itemLines = order.order_items.map((item, index) => {
    const productName = resolveProductName(item.products);
    const lineTotal = item.quantity * Number(item.unit_price);
    return `${index + 1}. ${escapeHtml(productName)} x${item.quantity} - ${formatPrice(lineTotal)}`;
  });

  const totalAmount = order.order_items.reduce((sum, item) => {
    return sum + item.quantity * Number(item.unit_price);
  }, 0);

  return [
    '<b>New SwiftShop order</b>',
    '',
    `<b>Customer:</b> ${escapeHtml(order.customer_name)}`,
    `<b>Phone:</b> ${escapeHtml(order.phone)}`,
    `<b>Address:</b> ${escapeHtml(order.address)}`,
    `<b>Status:</b> ${escapeHtml(order.status)}`,
    `<b>Placed:</b> ${escapeHtml(orderDate)}`,
    '',
    '<b>Items</b>',
    ...itemLines,
    '',
    `<b>Total:</b> ${formatPrice(totalAmount)}`,
    `<b>Order ID:</b> <code>${escapeHtml(order.id)}</code>`,
  ].join('\n');
}

function resolveProductName(
  products: { name: string } | Array<{ name: string }> | null,
): string {
  if (Array.isArray(products)) {
    return products[0]?.name ?? 'Unknown product';
  }

  return products?.name ?? 'Unknown product';
}

function formatPrice(value: number): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'EUR',
  }).format(value);
}

function escapeHtml(value: string): string {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
}

function delay(milliseconds: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'Content-Type': 'application/json',
    },
  });
}
