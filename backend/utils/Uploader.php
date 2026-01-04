<?php
namespace Utils;

class Uploader
{
    private string $basePath;   // /data/data/…/backend/uploads
    private string $baseUrl;    // http://localhost:8000/uploads

    public function __construct(string $basePath, string $baseUrl)
    {
        $this->basePath = rtrim($basePath, '/');
        $this->baseUrl  = rtrim($baseUrl, '/');
    }

    /**
     * @param array $fileItem  $_FILES['images']['tmp_name'][i]…
     * @return string URL pública del archivo guardado
     * @throws \RuntimeException
     */
    public function saveFile(array $fileItem, string $subDir): string
    {
        $tmp   = $fileItem['tmp_name'];
        $error = $fileItem['error'];
        if ($error !== UPLOAD_ERR_OK || !is_uploaded_file($tmp)) {
            throw new \RuntimeException('Upload err '. $error);
        }

        // generar nombre único
        $ext   = strtolower(pathinfo($fileItem['name'], PATHINFO_EXTENSION));
        $name  = bin2hex(random_bytes(8)) . '.' . $ext;
        $dir   = $this->basePath . '/' . trim($subDir, '/');
        if (!is_dir($dir) && !mkdir($dir, 0755, true)) {
            throw new \RuntimeException('No se pudo crear dir');
        }
        $target = $dir . '/' . $name;
        if (!move_uploaded_file($tmp, $target)) {
            throw new \RuntimeException('Error al mover archivo');
        }
        return $this->baseUrl . '/' . trim($subDir, '/') . '/' . $name;
    }
}

