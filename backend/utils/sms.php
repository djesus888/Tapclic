<?php
require_once __DIR__ . '/../../vendor/autoload.php';
use Twilio\Rest\Client;

class SMS {
    private static function client(): Client {
        $sid   = 'TU_TWILIO_ACCOUNT_SID';
        $token = 'TU_TWILIO_AUTH_TOKEN';
        return new Client($sid, $token);
    }

    public static function send(string $to, string $message): bool {
        try {
            $twilioNumber = 'TU_TWILIO_PHONE_NUMBER';
            self::client()->messages->create($to, [
                'from' => $twilioNumber,
                'body' => $message
            ]);
            return true;
        } catch (\Exception $e) {
            error_log("Error enviando SMS: " . $e->getMessage());
            return false;
        }
    }
}
