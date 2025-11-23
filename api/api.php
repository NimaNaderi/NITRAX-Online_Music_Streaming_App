<?php
require_once 'db_connection.php';

header('Content-Type: application/json; charset=utf-8');

$response = [
    'success' => false,
    'data'    => [],
    'message' => ''
];

try {
    $pdo = get_db_connection();

    if (isset($_GET['q']) && !empty(trim($_GET['q']))) {
        
        $search_term = '%' . trim($_GET['q']) . '%';

        $sql = "SELECT id, song, artist, videoCover, photo, duration, bg_colors, videoLink FROM music WHERE song LIKE ?";
        
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

} catch (Exception $e) {
    http_response_code(500);
    $response['message'] = 'Server Error: ' . $e->getMessage();
}

echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?>
