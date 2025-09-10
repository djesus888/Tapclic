<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';

class UserAdmin
{
    private \PDO $db;

    public function __construct()
    {
        $this->db = (new Database())->getConnection();
    }

    /**
     * Devuelve array con items + totales para paginar.
     *
     * @param int    $page
     * @param int    $limit
     * @param string $search
     * @param string $role
     * @param string $active  "1"|"0"|""
     * @return array
     */
    public function getPaginated(
        int    $page   = 1,
        int    $limit  = 15,
        string $search = '',
        string $role   = '',
        string $active = ''
    ): array {
        $offset = ($page - 1) * $limit;

        /* ---- where dinámico ---- */
        $where = [];
        $args  = [];

        if ($search !== '') {
            $where[] = "(name LIKE :s OR email LIKE :s OR phone LIKE :s)";
            $args[':s'] = "%$search%";
        }
        if ($role !== '') {
            $where[] = "role = :role";
            $args[':role'] = $role;
        }
        if ($active !== '') {
            $where[] = "active = :active";
            $args[':active'] = (int)$active;
        }

        $sqlWhere = $where ? 'WHERE ' . implode(' AND ', $where) : '';

        /* ---- total ---- */
        $stmt = $this->db->prepare("SELECT COUNT(*) FROM users $sqlWhere");
        foreach ($args as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int)$stmt->fetchColumn();

        /* ---- filas ---- */
        $stmt = $this->db->prepare(
            "SELECT id, name, email, phone, role, avatar_url, active
               FROM users
               $sqlWhere
               ORDER BY id DESC
               LIMIT :limit OFFSET :offset"
        );
        foreach ($args as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit',  $limit,  \PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, \PDO::PARAM_INT);
        $stmt->execute();
        $rows = $stmt->fetchAll(\PDO::FETCH_ASSOC);

        return [
            'data'         => $rows,
            'current_page' => $page,
            'last_page'    => (int)ceil($total / $limit),
            'total'        => $total,
            'from'         => $offset + 1,
            'to'           => min($offset + $limit, $total),
        ];
    }

    /* ---- opcional: eliminar usuario ---- */
    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare("DELETE FROM users WHERE id = :id");
        $stmt->execute([':id' => $id]);
        return $stmt->rowCount() > 0;
    }
}
