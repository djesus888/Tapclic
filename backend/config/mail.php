<?php
// backend/config/mail.php

return [
    'host' => 'smtp.gmail.com', // o tu servidor SMTP
    'port' => 587,
    'encryption' => 'tls',
    'username' => getenv('MAIL_USERNAME') ?: 'tu-email@gmail.com',
    'password' => getenv('MAIL_PASSWORD') ?: 'tu-contraseña',
    'from_email' => getenv('MAIL_FROM') ?: 'noreply@tapclic.com',
    'from_name' => 'TapClic'
];
