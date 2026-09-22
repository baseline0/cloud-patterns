#!/bin/bash
set -e

# Update system
yum update -y
yum install -y httpd php php-mysql

# Create simple PHP app
cat > /var/www/html/index.php << 'PHP'
<?php
// Database connection
$db_endpoint = getenv('DB_ENDPOINT');
$db_name = getenv('DB_NAME');
$db_user = getenv('DB_USER');
$db_pass = getenv('DB_PASS');

$hostname = parse_url("mysql://$db_endpoint")['host'] ?? 'localhost';

header('Content-Type: application/json');

try {
    $pdo = new PDO(
        "mysql:host=$hostname;dbname=$db_name",
        $db_user,
        $db_pass,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo json_encode([
        "status" => "healthy",
        "instance" => gethostname(),
        "timestamp" => date('Y-m-d H:i:s'),
        "database" => "connected"
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "unhealthy",
        "error" => $e->getMessage()
    ]);
}
?>
PHP

# Start Apache
systemctl start httpd
systemctl enable httpd
