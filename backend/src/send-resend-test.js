require('dotenv').config();
const { Resend } = require('resend');

const apiKey = (process.env.RESEND_API_KEY || 're_xxxxxxxxx').trim();

if (!apiKey || apiKey === 're_xxxxxxxxx') {
  console.error(
    'Set RESEND_API_KEY in backend/.env. Replace re_xxxxxxxxx with your real API key.'
  );
  process.exit(1);
}

const resend = new Resend(apiKey);

async function run() {
  try {
    const result = await resend.emails.send({
      from: process.env.MAIL_FROM || 'onboarding@resend.dev',
      to: process.env.TEST_EMAIL_TO || 'altyn2305@bk.ru',
      subject: 'Hello World',
      html: '<p>Congrats on sending your <strong>first email</strong>!</p>',
    });

    if (result?.error) {
      console.error('Resend returned error:', result.error);
      process.exit(1);
    }

    console.log('Email sent:', result);
  } catch (error) {
    console.error('Resend send failed:', error);
    process.exit(1);
  }
}

run();
