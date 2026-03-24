<?php
// models/PaymentMethod.php

require_once __DIR__ . '/../config/database.php';

class PaymentMethod {
    private $conn;
    private $table = 'payment_methods';

    public function __construct() {
        $this->conn = (new Database())->getConnection();
    }

    /**
     * Obtener todos los métodos de pago activos
     */
    public function getActiveMethods(): array {
        $query = "SELECT value, label, title, fields, concept 
                  FROM {$this->table} 
                  WHERE is_active = 1 
                  ORDER BY id ASC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        $methods = [];
        $details = [];
        
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            // Para la lista de métodos
            $methods[] = [
                'value' => $row['value'],
                'label' => $row['label']
            ];
            
            // Para los detalles (parsear el JSON de fields)
            $details[$row['value']] = [
                'value' => $row['value'],
                'label' => $row['label'],
                'title' => $row['title'],
                'fields' => json_decode($row['fields'], true) ?? [],
                'concept' => $row['concept']
            ];
        }
        
        return [
            'methods' => $methods,
            'details' => $details
        ];
    }

    /**
     * Obtener todos los métodos de pago (incluyendo inactivos) - para admin
     */
    public function getAllMethods(): array {
        $query = "SELECT * FROM {$this->table} ORDER BY id ASC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        $methods = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $row['fields'] = json_decode($row['fields'], true);
            $methods[] = $row;
        }
        
        return $methods;
    }

    /**
     * Obtener un método de pago por su valor
     */
    public function findByValue(string $value): ?array {
        $query = "SELECT * FROM {$this->table} WHERE value = :value AND is_active = 1 LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([':value' => $value]);
        
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($result) {
            $result['fields'] = json_decode($result['fields'], true);
        }
        
        return $result ?: null;
    }

    /**
     * Crear un nuevo método de pago (solo admin)
     */
    public function create(array $data): int {
        $query = "INSERT INTO {$this->table} 
                  (value, label, title, fields, concept, is_active) 
                  VALUES 
                  (:value, :label, :title, :fields, :concept, :is_active)";
        
        $stmt = $this->conn->prepare($query);
        $stmt->execute([
            ':value' => $data['value'],
            ':label' => $data['label'],
            ':title' => $data['title'] ?? null,
            ':fields' => json_encode($data['fields'] ?? [], JSON_UNESCAPED_UNICODE),
            ':concept' => $data['concept'] ?? null,
            ':is_active' => $data['is_active'] ?? 1
        ]);
        
        return $this->conn->lastInsertId();
    }

    /**
     * Actualizar un método de pago (solo admin)
     */
    public function update(int $id, array $data): bool {
        $fields = [];
        $params = [':id' => $id];
        
        if (isset($data['value'])) {
            $fields[] = "value = :value";
            $params[':value'] = $data['value'];
        }
        if (isset($data['label'])) {
            $fields[] = "label = :label";
            $params[':label'] = $data['label'];
        }
        if (isset($data['title'])) {
            $fields[] = "title = :title";
            $params[':title'] = $data['title'];
        }
        if (isset($data['fields'])) {
            $fields[] = "fields = :fields";
            $params[':fields'] = json_encode($data['fields'], JSON_UNESCAPED_UNICODE);
        }
        if (isset($data['concept'])) {
            $fields[] = "concept = :concept";
            $params[':concept'] = $data['concept'];
        }
        if (isset($data['is_active'])) {
            $fields[] = "is_active = :is_active";
            $params[':is_active'] = $data['is_active'];
        }
        
        if (empty($fields)) {
            return false;
        }
        
        $query = "UPDATE {$this->table} SET " . implode(', ', $fields) . " WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        return $stmt->execute($params);
    }

    /**
     * Eliminar/desactivar un método de pago (solo admin)
     */
    public function delete(int $id): bool {
        $query = "UPDATE {$this->table} SET is_active = 0 WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        return $stmt->execute([':id' => $id]);
    }
}
