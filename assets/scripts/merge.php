<?php
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Check if files are uploaded
    if (isset($_FILES['file1']) && isset($_FILES['file2'])) {
        $file1 = $_FILES['file1']['tmp_name'];
        $file2 = $_FILES['file2']['tmp_name'];

        // Merge bookmarks and get the JSON string
        $mergedJson = mergeBookmarksNested($file1, $file2);

        // Set headers to prompt download
        header('Content-Type: application/json');
        header('Content-Disposition: attachment; filename="merged_bookmarks.json"');
        header('Content-Length: ' . strlen($mergedJson));

        // Output the merged bookmarks as JSON
        echo $mergedJson;
    } else {
        echo "Please upload both files.";
    }
}

function mergeBookmarksNested($file1, $file2) {
    // Read JSON files
    $json1 = json_decode(file_get_contents($file1), true);
    $json2 = json_decode(file_get_contents($file2), true);

    // Create an associative array to hold merged bookmarks
    $mergedBookmarks = [];

    // Convert the arrays to an associative array indexed by id for easier access
    $bookmarks1 = array_column($json1, null, 'id');
    $bookmarks2 = array_column($json2, null, 'id');

    // Add bookmarks from both files
    addBookmarks($mergedBookmarks, $bookmarks1);
    addBookmarks($mergedBookmarks, $bookmarks2);

    // Return the merged bookmarks as a JSON string
    return json_encode(array_values($mergedBookmarks), JSON_PRETTY_PRINT);
}

function getDepth($bookmark, $bookmarks) {
    $depth = 0;
    $currentId = $bookmark['parentId'];

    while ($currentId !== null && isset($bookmarks[$currentId])) {
        $depth++;
        $currentId = $bookmarks[$currentId]['parentId'];
    }

    return $depth;
}

function addBookmarks(&$merged, $bookmarks) {
    foreach ($bookmarks as $bookmark) {
        $id = $bookmark['id'];
        // If the bookmark ID already exists, compare their depths
        if (isset($merged[$id])) {
            // Calculate depths
            $existingDepth = getDepth($merged[$id], $merged);
            $newDepth = getDepth($bookmark, $merged);

            // Keep the bookmark with the greater depth
            if ($newDepth > $existingDepth) {
                $merged[$id] = $bookmark;
            }
        } else {
            $merged[$id] = $bookmark;
        }
    }
}
