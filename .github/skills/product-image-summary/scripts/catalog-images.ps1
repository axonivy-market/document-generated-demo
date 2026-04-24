param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    [string]$OutputFile = ""
)

$imageExtensions = @("png", "jpg", "jpeg", "gif", "svg", "webp", "tiff", "tif", "bmp", "ico", "mp4")

function Resolve-ImagesDir {
    param([string]$Name)
    foreach ($c in @("$Name/images", $Name)) {
        if (Test-Path $c -PathType Container) { return (Resolve-Path $c).Path }
    }
    return $null
}

function Get-AltText {
    param([string]$Filename)
    $stem = [IO.Path]::GetFileNameWithoutExtension($Filename) -replace '[-_]', ' '
    return (Get-Culture).TextInfo.ToTitleCase($stem.ToLower())
}

function Get-FileSize {
    param([long]$Bytes)
    if ($Bytes -ge 1MB) { return "{0:N1} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return "{0:N0} KB" -f ($Bytes / 1KB) }
    return "$Bytes B"
}

function Get-SectionTitle {
    param([string]$RelDir)
    if (-not $RelDir) { return "General" }
    return ($RelDir -split '[/\\]' | ForEach-Object {
        (Get-Culture).TextInfo.ToTitleCase(($_ -replace '[-_]', ' ').ToLower())
    }) -join ' / '
}

function Get-ReadmePlacement {
    param([string]$Section)
    $s = $Section.ToLower()
    if ($s -match 'demo')               { return '## Demo' }
    if ($s -match 'setup|install')      { return '## Setup' }
    if ($s -match 'component|feature')  { return '## Components' }
    return '## Screenshots'
}

# --- main ---

$imagesDir = Resolve-ImagesDir -Name $ProjectName
if (-not $imagesDir) {
    Write-Error "Could not find directory for: $ProjectName"
    Write-Error "Tried: ./$ProjectName/images, ./$ProjectName/"
    exit 1
}

Write-Host "Scanning: $imagesDir" -ForegroundColor Cyan

$allImages = Get-ChildItem -Path $imagesDir -Recurse -File |
    Where-Object { $imageExtensions -contains $_.Extension.TrimStart('.').ToLower() }

if (-not $allImages) {
    Write-Warning "No images found in: $imagesDir"
    exit 0
}

# Group images by sub-directory relative to the images root
$groups = [ordered]@{}
foreach ($img in $allImages) {
    $rel    = $img.FullName.Substring($imagesDir.Length).TrimStart('\','/')
    $subdir = (Split-Path $rel -Parent) -replace '\\', '/'
    if (-not $groups.Contains($subdir)) {
        $groups[$subdir] = [System.Collections.Generic.List[object]]::new()
    }
    $groups[$subdir].Add($img)
}

$cwd = (Get-Location).Path
$out = [System.Text.StringBuilder]::new()

[void]$out.AppendLine("# Image Summary: $ProjectName")
[void]$out.AppendLine("")
[void]$out.AppendLine("Source: ``$($imagesDir.Substring($cwd.Length + 1) -replace '\\','/')``")
[void]$out.AppendLine("Total: $($allImages.Count) image(s)")
[void]$out.AppendLine("")
[void]$out.AppendLine("---")
[void]$out.AppendLine("")

foreach ($subdir in $groups.Keys) {
    $section   = Get-SectionTitle -RelDir $subdir
    $placement = Get-ReadmePlacement -Section $section
    $imgs      = $groups[$subdir]

    [void]$out.AppendLine("## $section ($($imgs.Count))")
    [void]$out.AppendLine("")
    [void]$out.AppendLine("> Suggested readme placement: ``$placement``")
    [void]$out.AppendLine("")

    foreach ($img in $imgs) {
        $relCwd = $img.FullName.Substring($cwd.Length + 1) -replace '\\', '/'
        $alt    = Get-AltText -Filename $img.Name
        $size   = Get-FileSize -Bytes $img.Length

        [void]$out.AppendLine("### $alt")
        [void]$out.AppendLine("- **File:** ``$relCwd``")
        [void]$out.AppendLine("- **Size:** $size")
        [void]$out.AppendLine("")
        [void]$out.AppendLine('```markdown')
        [void]$out.AppendLine("![$alt]($relCwd)")
        [void]$out.AppendLine('```')
        [void]$out.AppendLine("")
        [void]$out.AppendLine("---")
        [void]$out.AppendLine("")
    }
}

$result = $out.ToString()

if ($OutputFile) {
    $result | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Host "[+] Saved to: $OutputFile" -ForegroundColor Green
} else {
    Write-Output $result
}
