import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (request.method !== "POST") return new Response("Method not allowed", { status: 405, headers: cors });

  const enquiry = await request.json();
  const resendKey = Deno.env.get("RESEND_API_KEY");
  if (!resendKey) return new Response("RESEND_API_KEY is not configured", { status: 500, headers: cors });

  const lines = Object.entries(enquiry).map(([key, value]) => `${key}: ${value ?? "—"}`).join("\n");
  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${resendKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: Deno.env.get("NOTIFY_FROM") || "DivineGrow Website <onboarding@resend.dev>",
      to: ["cemde.pankaj@gmail.com"],
      reply_to: enquiry.email,
      subject: `New DivineGrow enquiry: ${enquiry.company || enquiry.name}`,
      text: lines,
    }),
  });

  if (!response.ok) return new Response(await response.text(), { status: 502, headers: cors });
  return new Response(JSON.stringify({ sent: true }), {
    headers: { ...cors, "Content-Type": "application/json" },
  });
});
