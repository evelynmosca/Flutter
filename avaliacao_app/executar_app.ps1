param(
    [ValidateSet('chrome', 'emulator-5554')]
    [string]$Dispositivo = 'chrome'
)

$ErrorActionPreference = 'Stop'
$caminhoProjeto = $PSScriptRoot

Push-Location -LiteralPath $caminhoProjeto
try {
    & (Join-Path $caminhoProjeto 'iniciar_api.ps1')
    & flutter run -d $Dispositivo
    if ($LASTEXITCODE -ne 0) {
        throw "Não foi possível executar o Flutter em $Dispositivo."
    }
} finally {
    Pop-Location
}
