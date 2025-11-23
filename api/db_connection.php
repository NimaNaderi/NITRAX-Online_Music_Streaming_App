<?php
$host    = 'services.irn8.chabokan.net';
$db      = 'mabel'; 
$user    = 'root';
$pass    = 'Xe5KbxR7yefNbVrF'; 
$charset = 'utf8mb4';
$port    = '10778';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset;port=$port";

$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

function get_db_connection() {
    global $dsn, $user, $pass, $options;
    
    try {
        $pdo = new PDO($dsn, $user, $pass, $options);
        return $pdo;
    } catch (\PDOException $e) {
        throw new Exception("Datenbankverbindungsfehler: " . $e->getMessage());
    }
}
?>
