<?php
header('Content-Type: application/json; charset=utf-8');

$host = 'services.irn8.chabokan.net';
$db   = 'mabel'; 
$user = 'root';
$pass = 'Xe5KbxR7yefNbVrF'; 
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset;port=10778";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

$response = [
    'success' => false,
    'data'    => [],
    'message' => ''
];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);

    if (isset($_GET['q']) && !empty(trim($_GET['q']))) {
        
        $search_term = '%' . trim($_GET['q']) . '%';

        $sql = "SELECT id, song, artist, videoCover, photo, duration, bg_colors, videoLink, FROM music WHERE song LIKE ?";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$search_term]);

        $songs = $stmt->fetchAll();

        $response['success'] = true;
        $response['data'] = $songs;
        $response['message'] = 'Search success (' . count($songs) . ' items)';

    } else {
        http_response_code(400);
        $response['message'] = 'Query is required';
    }

} catch (\PDOException $e) {
    http_response_code(500);
    $response['message'] = 'Database Error: ' . $e->getMessage();
}

echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

?>