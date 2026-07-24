<?php
require_once __DIR__ . '/../config/database.php';

class CompanyController
{
    private $conn;

    public function __construct()
    {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    // GET /api/company
    public function index(): void
    {
        header("Content-Type: application/json; charset=UTF-8");

        try {
            // Obtener datos de la empresa desde system_config
            $stmt = $this->conn->prepare("
                SELECT company_name, company_address, company_phone, company_email,
                       company_mission, company_vision, company_years,
                       company_founded, company_clients
                FROM system_config WHERE id = 1 LIMIT 1
            ");
            $stmt->execute();
            $config = $stmt->fetch(PDO::FETCH_ASSOC);

            // Obtener directivos - SOLO usuarios con position definido
            $stmt2 = $this->conn->prepare("
                SELECT id, name, email, phone, avatar_url, role,
                       bio, position, linkedin_url, twitter_url
                FROM users
                WHERE position IS NOT NULL
                  AND position != ''
                  AND position != 'team'
                ORDER BY
                    CASE
                        WHEN position = 'founder' THEN 1
                        WHEN position = 'director' THEN 2
                        WHEN position = 'subdirector' THEN 3
                        ELSE 4
                    END
                LIMIT 6
            ");
            $stmt2->execute();
            $executives = $stmt2->fetchAll(PDO::FETCH_ASSOC);

            // Formatear directivos
            $teamMembers = array_map(function($member) {
                return [
                    'id' => (int)$member['id'],
                    'name' => $member['name'],
                    'email' => $member['email'],
                    'phone' => $member['phone'],
                    'avatar' => $member['avatar_url'] ?? null,
                    'role' => $member['role'],
                    'bio' => $member['bio'] ?? '',
                    'position' => $member['position'] ?? 'team',
                    'social' => [
                        'linkedin' => $member['linkedin_url'] ?? null,
                        'twitter' => $member['twitter_url'] ?? null,
                        'email' => $member['email'] ?? null
                    ]
                ];
            }, $executives);

            // ✅ Hitos desde la BD
            $stmt3 = $this->conn->prepare("
                SELECT year, title, description, icon
                FROM company_milestones
                WHERE is_active = 1
                ORDER BY sort_order ASC
            ");
            $stmt3->execute();
            $milestones = $stmt3->fetchAll(PDO::FETCH_ASSOC);

            echo json_encode([
                'success' => true,
                'data' => [
                    'company' => [
                        'name' => $config['company_name'] ?? 'TapClic',
                        'mission' => $config['company_mission'] ?? 'Conectar profesionales con clientes que necesitan servicios de calidad.',
                        'vision' => $config['company_vision'] ?? 'Ser la plataforma líder en servicios profesionales.',
                        'years' => $config['company_years'] ?? '5+',
                        'founded' => $config['company_founded'] ?? '2020',
                        'address' => $config['company_address'] ?? '',
                        'phone' => $config['company_phone'] ?? '',
                        'email' => $config['company_email'] ?? ''
                    ],
                    'team' => $teamMembers,
                    'milestones' => $milestones,
                    'clients' => (int)($config['company_clients'] ?? 150)
                ]
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al obtener datos: ' . $e->getMessage()]);
        }
    }
}
