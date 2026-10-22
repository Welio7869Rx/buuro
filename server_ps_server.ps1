$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()
Write-Host "Listening on http://localhost:8080/"

function Get-ContentType {
    param([string]$extension)

    switch ($extension.ToLower()) {
        '.html' { return 'text/html' }
        '.htm'  { return 'text/html' }
        '.css'  { return 'text/css' }
        '.js'   { return 'application/javascript' }
        '.json' { return 'application/json' }
        '.png'  { return 'image/png' }
        '.jpg'  { return 'image/jpeg' }
        '.jpeg' { return 'image/jpeg' }
        '.gif'  { return 'image/gif' }
        '.svg'  { return 'image/svg+xml' }
        '.ico'  { return 'image/x-icon' }
        '.wav'  { return 'audio/wav' }
        '.mp3'  { return 'audio/mpeg' }
        '.txt'  { return 'text/plain' }
        default { return 'application/octet-stream' }
    }
}

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    $path = $request.Url.AbsolutePath.TrimStart('/')
    $path = [System.Uri]::UnescapeDataString($path)

    if ($path -eq '') {
        if (Test-Path "index.html") {
            $path = 'index.html'
        } elseif (Test-Path "jogo-forca-completo.html") {
            $path = 'jogo-forca-completo.html'
        }
    }

    if ($path -match '\.\.') {
        $response.StatusCode = 400
        $response.ContentType = 'text/plain'
        $buf = [System.Text.Encoding]::UTF8.GetBytes('400 Bad Request')
        $response.OutputStream.Write($buf, 0, $buf.Length)
        $response.OutputStream.Close()
        continue
    }

    $file = Join-Path (Get-Location) $path
    if (Test-Path $file) {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $response.ContentType = Get-ContentType ([System.IO.Path]::GetExtension($file))
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $response.StatusCode = 404
        $response.ContentType = 'text/plain'
        $buf = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $path")
        $response.OutputStream.Write($buf, 0, $buf.Length)
    }

    $response.OutputStream.Close()
}
