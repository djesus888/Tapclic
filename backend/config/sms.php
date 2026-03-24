<?php
// backend/config/sms.php

return [
    'twilio_sid' => getenv('TWILIO_SID') ?: 'ACxxxxxxxxxxxxxx',
    'twilio_token' => getenv('TWILIO_TOKEN') ?: 'your-auth-token',
    'twilio_phone' => getenv('TWILIO_PHONE') ?: '+1234567890'
];
