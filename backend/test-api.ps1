# Script de teste para a API de Estoque (PowerShell)
# Execute: .\test-api.ps1

$API_BASE = "http://localhost:3001"
$TOKEN = ""

Write-Host "Testando API de Estoque..." -ForegroundColor Cyan
Write-Host ""

# 1. Healthcheck
Write-Host "[1] Testando Healthcheck..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$API_BASE/api/health" -Method Get
    Write-Host "[OK] Healthcheck OK" -ForegroundColor Green
    $response | ConvertTo-Json
} catch {
    Write-Host "[ERRO] Healthcheck falhou: $_" -ForegroundColor Red
}
Write-Host ""

# 2. Listar produtos
Write-Host "[2] Listando produtos..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$API_BASE/api/products" -Method Get
    Write-Host "[OK] Produtos listados" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "[ERRO] Falha ao listar produtos: $_" -ForegroundColor Red
}
Write-Host ""

# 3. Consultar estoque
Write-Host "[3] Consultando estoque por SKU..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$API_BASE/api/stock?sku=IPHN-15-PNK" -Method Get
    Write-Host "[OK] Estoque consultado" -ForegroundColor Green
    $response | ConvertTo-Json
} catch {
    Write-Host "[ERRO] Falha ao consultar estoque: $_" -ForegroundColor Red
}
Write-Host ""

# 4. Registrar usuário
Write-Host "[4] Registrando novo usuario..." -ForegroundColor Yellow
try {
    $body = @{
        email = "teste@example.com"
        password = "senha123"
        name = "Usuario Teste"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$API_BASE/api/auth/register" -Method Post -Body $body -ContentType "application/json"
    Write-Host "[OK] Usuario registrado" -ForegroundColor Green
    $response | ConvertTo-Json
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 400) {
        Write-Host "[INFO] Usuario ja existe (esperado)" -ForegroundColor Yellow
    } else {
        Write-Host "[ERRO] Falha ao registrar: $_" -ForegroundColor Red
    }
}
Write-Host ""

# 5. Login
Write-Host "[5] Fazendo login como admin..." -ForegroundColor Yellow
try {
    $body = @{
        email = "admin@example.com"
        password = "admin123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$API_BASE/api/auth/login" -Method Post -Body $body -ContentType "application/json"
    $TOKEN = $response.token
    Write-Host "[OK] Login realizado" -ForegroundColor Green
    Write-Host "Token: $($TOKEN.Substring(0, [Math]::Min(50, $TOKEN.Length)))..." -ForegroundColor Gray
    $response | ConvertTo-Json
} catch {
    Write-Host "[ERRO] Falha no login: $_" -ForegroundColor Red
    Write-Host "[AVISO] Sem token, pulando testes protegidos..." -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# 6. Atualizar estoque (PUT)
Write-Host "[6] Atualizando estoque (PUT)..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $TOKEN"
        "Content-Type" = "application/json"
    }
    $body = @{
        stock = 100
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$API_BASE/api/products/1/stock" -Method Put -Headers $headers -Body $body
    Write-Host "[OK] Estoque atualizado" -ForegroundColor Green
    $response | ConvertTo-Json
} catch {
    Write-Host "[ERRO] Falha ao atualizar estoque: $_" -ForegroundColor Red
}
Write-Host ""

# 7. Ajustar estoque (PATCH)
Write-Host "[7] Ajustando estoque (PATCH - delta -5)..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $TOKEN"
        "Content-Type" = "application/json"
    }
    $body = @{
        delta = -5
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$API_BASE/api/products/1/stock" -Method Patch -Headers $headers -Body $body
    Write-Host "[OK] Estoque ajustado" -ForegroundColor Green
    $response | ConvertTo-Json
} catch {
    Write-Host "[ERRO] Falha ao ajustar estoque: $_" -ForegroundColor Red
}
Write-Host ""

# 8. Verificar produto por ID
Write-Host "[8] Buscando produto por ID..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$API_BASE/api/products/1" -Method Get
    Write-Host "[OK] Produto encontrado" -ForegroundColor Green
    $response | ConvertTo-Json
} catch {
    Write-Host "[ERRO] Falha ao buscar produto: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "Testes concluidos!" -ForegroundColor Cyan

