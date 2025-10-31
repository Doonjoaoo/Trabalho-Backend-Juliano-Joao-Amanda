#!/bin/bash

# Script de teste para a API de Estoque
# Execute: bash test-api.sh

API_BASE="http://localhost:3001"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🧪 Testando API de Estoque..."
echo ""

# 1. Healthcheck
echo "1️⃣ Testando Healthcheck..."
response=$(curl -s -w "\n%{http_code}" "$API_BASE/api/health")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')
if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✅ Healthcheck OK${NC}"
    echo "$body" | jq .
else
    echo -e "${RED}❌ Healthcheck falhou (HTTP $http_code)${NC}"
fi
echo ""

# 2. Listar produtos
echo "2️⃣ Listando produtos..."
response=$(curl -s -w "\n%{http_code}" "$API_BASE/api/products")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')
if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✅ Produtos listados${NC}"
    echo "$body" | jq .
else
    echo -e "${RED}❌ Falha ao listar produtos (HTTP $http_code)${NC}"
fi
echo ""

# 3. Consultar estoque
echo "3️⃣ Consultando estoque por SKU..."
response=$(curl -s -w "\n%{http_code}" "$API_BASE/api/stock?sku=IPHN-15-PNK")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')
if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✅ Estoque consultado${NC}"
    echo "$body" | jq .
else
    echo -e "${RED}❌ Falha ao consultar estoque (HTTP $http_code)${NC}"
fi
echo ""

# 4. Registrar usuário
echo "4️⃣ Registrando novo usuário..."
response=$(curl -s -w "\n%{http_code}" -X POST "$API_BASE/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"teste@example.com","password":"senha123","name":"Usuário Teste"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')
if [ "$http_code" = "201" ] || [ "$http_code" = "400" ]; then
    if [ "$http_code" = "201" ]; then
        echo -e "${GREEN}✅ Usuário registrado${NC}"
    else
        echo -e "${GREEN}ℹ️ Usuário já existe (esperado)${NC}"
    fi
    echo "$body" | jq .
else
    echo -e "${RED}❌ Falha ao registrar (HTTP $http_code)${NC}"
    echo "$body"
fi
echo ""

# 5. Login
echo "5️⃣ Fazendo login como admin..."
response=$(curl -s -w "\n%{http_code}" -X POST "$API_BASE/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')
if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✅ Login realizado${NC}"
    TOKEN=$(echo "$body" | jq -r '.token')
    echo "Token: ${TOKEN:0:50}..."
    echo "$body" | jq .
else
    echo -e "${RED}❌ Falha no login (HTTP $http_code)${NC}"
    echo "$body"
    echo ""
    echo "⚠️ Sem token, pulando testes protegidos..."
    exit 1
fi
echo ""

# 6. Atualizar estoque (PUT)
echo "6️⃣ Atualizando estoque (PUT)..."
response=$(curl -s -w "\n%{http_code}" -X PUT "$API_BASE/api/products/1/stock" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"stock": 100}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')
if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✅ Estoque atualizado${NC}"
    echo "$body" | jq .
else
    echo -e "${RED}❌ Falha ao atualizar estoque (HTTP $http_code)${NC}"
    echo "$body"
fi
echo ""

# 7. Ajustar estoque (PATCH)
echo "7️⃣ Ajustando estoque (PATCH - delta -5)..."
response=$(curl -s -w "\n%{http_code}" -X PATCH "$API_BASE/api/products/1/stock" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"delta": -5}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')
if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✅ Estoque ajustado${NC}"
    echo "$body" | jq .
else
    echo -e "${RED}❌ Falha ao ajustar estoque (HTTP $http_code)${NC}"
    echo "$body"
fi
echo ""

# 8. Verificar produto por ID
echo "8️⃣ Buscando produto por ID..."
response=$(curl -s -w "\n%{http_code}" "$API_BASE/api/products/1")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')
if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✅ Produto encontrado${NC}"
    echo "$body" | jq .
else
    echo -e "${RED}❌ Falha ao buscar produto (HTTP $http_code)${NC}"
fi
echo ""

echo "✨ Testes concluídos!"

