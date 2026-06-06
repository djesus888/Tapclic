<?php

namespace Utils;

class Uploader
{
    private string $basePath;
    private string $baseUrl;

    /**
     * Categorías estándar de uploads
     */
    public const CAT_AVATARS   = 'avatars';
    public const CAT_SERVICES  = 'services';
    public const CAT_REVIEWS   = 'reviews';
    public const CAT_PAYMENTS  = 'payments';
    public const CAT_BILLING   = 'billing';
    public const CAT_MESSAGES  = 'messages';
    public const CAT_TICKETS   = 'tickets';
    public const CAT_SYSTEM    = 'system';
    public const CAT_UPDATES   = 'updates';

    public function __construct(string $basePath, string $baseUrl)
    {
        $this->basePath = rtrim($basePath, '/');
        $this->baseUrl  = rtrim($baseUrl, '/');
    }

    /**
     * Guarda un archivo subido y devuelve la URL pública.
     *
     * @param array  $fileItem  $_FILES['fieldname'] completo (con tmp_name, error, name)
     * @param string $subDir    Subcarpeta dentro de basePath (ej: 'reviews/123')
     * @return string URL pública del archivo guardado
     * @throws \RuntimeException
     */
    public function saveFile(array $fileItem, string $subDir = ''): string
    {
        $tmp   = $fileItem['tmp_name'] ?? '';
        $error = $fileItem['error'] ?? UPLOAD_ERR_NO_FILE;

        if ($error !== UPLOAD_ERR_OK || empty($tmp) || !is_uploaded_file($tmp)) {
            throw new \RuntimeException('Upload error code: ' . $error);
        }

        // Generar nombre único seguro
        $ext  = strtolower(pathinfo($fileItem['name'] ?? '', PATHINFO_EXTENSION));
        $name = bin2hex(random_bytes(8)) . ($ext ? '.' . $ext : '');

        $dir = $this->basePath;
        if ($subDir !== '') {
            $dir .= '/' . trim($subDir, '/');
        }

        if (!is_dir($dir) && !mkdir($dir, 0755, true)) {
            throw new \RuntimeException('No se pudo crear directorio: ' . $dir);
        }

        $target = $dir . '/' . $name;
        if (!move_uploaded_file($tmp, $target)) {
            throw new \RuntimeException('Error al mover archivo a: ' . $target);
        }

        $urlPath = trim($subDir, '/');
        return $this->baseUrl . ($urlPath ? '/' . $urlPath : '') . '/' . $name;
    }

    /**
     * Devuelve la ruta base de almacenamiento.
     */
    public function getBasePath(): string
    {
        return $this->basePath;
    }

    /**
     * Devuelve la URL base pública.
     */
    public function getBaseUrl(): string
    {
        return $this->baseUrl;
    }
}
