$ErrorActionPreference = 'Stop'
$caminhoProjeto = $PSScriptRoot
$enderecoSaude = 'http://127.0.0.1:8765/saude'

& python (Join-Path $caminhoProjeto 'backend/popular_api.py')
if ($LASTEXITCODE -ne 0) {
    throw 'Não foi possível preparar o catálogo de exemplos.'
}

function Testar-ApiMercadinho {
    try {
        $resposta = Invoke-RestMethod -Uri $enderecoSaude -TimeoutSec 2
        return $resposta.status -eq 'ok'
    } catch {
        return $false
    }
}

if (-not (Testar-ApiMercadinho)) {
    $pythonMercadinho = (Get-Command python -ErrorAction Stop).Source
    Start-Process -FilePath $pythonMercadinho `
        -ArgumentList @('backend/servidor.py', '--host', '127.0.0.1', '--port', '8765') `
        -WorkingDirectory $caminhoProjeto -WindowStyle Hidden | Out-Null

    $pronto = $false
    for ($tentativa = 0; $tentativa -lt 20; $tentativa++) {
        Start-Sleep -Milliseconds 250
        if (Testar-ApiMercadinho) {
            $pronto = $true
            break
        }
    }
    if (-not $pronto) {
        throw 'A API não iniciou na porta 8765. Verifique se a porta está livre e se o Python está instalado.'
    }
}

$produtos = Invoke-RestMethod -Uri 'http://127.0.0.1:8765/produtos' -TimeoutSec 3
Write-Output "API do Mercadinho Genciana ativa em http://127.0.0.1:8765 com $(@($produtos).Count) produtos."
