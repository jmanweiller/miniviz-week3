$ErrorActionPreference = "Stop"
$ua = "miniviz-treemap/1.0 (educational; contact: jmanweiller@gmail.com)"
$root = "C:\Users\jmanw\claude projects\miniviz-week3"
$postersDir = Join-Path $root "posters"
if (-not (Test-Path $postersDir)) { New-Item -ItemType Directory -Path $postersDir | Out-Null }

function Get-Slug([string]$title) {
    $s = $title.ToLower()
    $s = ($s -replace '[^a-z0-9]+','-')
    $s = $s.Trim('-')
    return $s
}

# Map of CSV titles -> Wikipedia article titles (with disambiguation where needed)
$titleMap = @{
    "Iron Man" = "Iron Man (2008 film)"
    "The Incredible Hulk" = "The Incredible Hulk (film)"
    "Iron Man 2" = "Iron Man 2"
    "Thor" = "Thor (film)"
    "Captain America: The First Avenger" = "Captain America: The First Avenger"
    "The Avengers" = "The Avengers (2012 film)"
    "Iron Man 3" = "Iron Man 3"
    "Thor: The Dark World" = "Thor: The Dark World"
    "Captain America: The Winter Soldier" = "Captain America: The Winter Soldier"
    "Guardians of the Galaxy" = "Guardians of the Galaxy (film)"
    "Avengers: Age of Ultron" = "Avengers: Age of Ultron"
    "Ant-Man" = "Ant-Man (film)"
    "Captain America: Civil War" = "Captain America: Civil War"
    "Doctor Strange" = "Doctor Strange (2016 film)"
    "Guardians of the Galaxy Vol. 2" = "Guardians of the Galaxy Vol. 2"
    "Spider-Man: Homecoming" = "Spider-Man: Homecoming"
    "Thor: Ragnarok" = "Thor: Ragnarok"
    "Black Panther" = "Black Panther (film)"
    "Avengers: Infinity War" = "Avengers: Infinity War"
    "Ant-Man and the Wasp" = "Ant-Man and the Wasp"
    "Captain Marvel" = "Captain Marvel (film)"
    "Avengers: Endgame" = "Avengers: Endgame"
    "Spider-Man: Far From Home" = "Spider-Man: Far From Home"
    "Black Widow" = "Black Widow (2021 film)"
    "Shang-Chi and the Legend of the Ten Rings" = "Shang-Chi and the Legend of the Ten Rings"
    "Eternals" = "Eternals (film)"
    "Spider-Man: No Way Home" = "Spider-Man: No Way Home"
    "Doctor Strange in the Multiverse of Madness" = "Doctor Strange in the Multiverse of Madness"
    "Thor: Love and Thunder" = "Thor: Love and Thunder"
    "Black Panther: Wakanda Forever" = "Black Panther: Wakanda Forever"
    "Ant-Man and the Wasp: Quantumania" = "Ant-Man and the Wasp: Quantumania"
    "Guardians of the Galaxy Vol. 3" = "Guardians of the Galaxy Vol. 3"
    "The Marvels" = "The Marvels"
    "Deadpool & Wolverine" = "Deadpool & Wolverine"
    "Captain America: Brave New World" = "Captain America: Brave New World"
    "Thunderbolts*" = "Thunderbolts (film)"
    "The Fantastic Four: First Steps" = "The Fantastic Four: First Steps"
}

$films = Import-Csv (Join-Path $root "Data\mcu_films.csv")
$results = @()

foreach ($film in $films) {
    $title = $film.Title
    $slug = Get-Slug $title
    $wikiTitle = $titleMap[$title]
    if (-not $wikiTitle) { $wikiTitle = $title }
    $outPath = Join-Path $postersDir "$slug.jpg"

    if (Test-Path $outPath) {
        Write-Host "SKIP (exists): $title -> $slug.jpg"
        $results += [PSCustomObject]@{Title=$title; Slug=$slug; Status="exists"; Url=""}
        continue
    }

    try {
        $api = "https://en.wikipedia.org/w/api.php?action=query&titles=$([uri]::EscapeDataString($wikiTitle))&prop=pageimages&format=json&pithumbsize=300&piprop=thumbnail|name&pilicense=any&redirects=1"
        $r = Invoke-RestMethod -Uri $api -Headers @{ "User-Agent" = $ua }
        $page = $r.query.pages.PSObject.Properties.Value | Select-Object -First 1
        $thumbUrl = $page.thumbnail.source
        if (-not $thumbUrl) {
            Write-Host "NO IMAGE: $title (wiki: $wikiTitle)"
            $results += [PSCustomObject]@{Title=$title; Slug=$slug; Status="no-image"; Url=""}
            Start-Sleep -Milliseconds 500
            continue
        }
        # Download
        Invoke-WebRequest -Uri $thumbUrl -Headers @{ "User-Agent" = $ua } -OutFile $outPath
        $size = (Get-Item $outPath).Length
        Write-Host ("OK: {0,-45} -> {1}.jpg ({2} bytes)" -f $title, $slug, $size)
        $results += [PSCustomObject]@{Title=$title; Slug=$slug; Status="ok"; Url=$thumbUrl; Size=$size}
    } catch {
        Write-Host "ERROR: $title -- $($_.Exception.Message)"
        $results += [PSCustomObject]@{Title=$title; Slug=$slug; Status="error"; Url=""; Error=$_.Exception.Message}
    }
    Start-Sleep -Milliseconds 500
}

Write-Host "`n=== Summary ==="
$results | Group-Object Status | ForEach-Object { Write-Host "$($_.Name): $($_.Count)" }
$results | Where-Object { $_.Status -ne "ok" -and $_.Status -ne "exists" } | Format-Table -AutoSize
