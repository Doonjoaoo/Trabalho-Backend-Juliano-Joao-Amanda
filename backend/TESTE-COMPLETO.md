# 🧪 Guia Completo de Testes - API de Estoque

Este guia contém todos os comandos e exemplos para testar a API completamente.

## 📋 Pré-requisitos

1. **API rodando**:
   ```bash
   # Docker
   docker compose up -d
   
   # OU Local
   npm run build && npm start
   ```

2. **Ferramentas** (opcional):
   - **VS Code** com extensão "REST Client" (para `test-api.http`)
   - **Postman** ou **Insomnia** (alternativa)
   - **curl** (terminal)
   - **PowerShell** (Windows)

---

## 🚀 Formas de Testar

### **Opção 1: Script PowerShell (Windows) - RECOMENDADO**

```powershell
cd backend
.\test-api.ps1
```

### **Opção 2: Script Bash (Linux/Mac)**

```bash
cd backend
chmod +x test-api.sh
./test-api.sh
```

### **Opção 3: VS Code REST Client**

1. Instale a extensão "REST Client" no VS Code
2. Abra `test-api.http`
3. Clique em "Send Request" acima de cada requisição

### **Opção 4: Manual (curl)**

---

## 📝 Testes Manuais (curl)

### 1. Healthcheck

```bash
curl http://localhost:3001/api/health
```

**Resposta esperada:**
```json
{"ok":true,"timestamp":"2024-..."}
```

---

### 2. Listar Produtos

```bash
curl http://localhost:3001/api/products
```

**Resposta esperada:**
```json
[
  {
    "id": 1,
    "sku": "CASE-IPHN",
    "name": "Capinha para iPhone",
    "stock": 15,
    "createdAt": "...",
    "updatedAt": "..."
  },
  ...
]
```

---

### 3. Consultar Estoque por SKU

```bash
curl "http://localhost:3001/api/stock?sku=IPHN-15-PNK"
```

**Resposta esperada:**
```json
{
  "id": 3,
  "sku": "IPHN-15-PNK",
  "stock": 7
}
```

---

### 4. Consultar Estoque por ID

```bash
curl "http://localhost:3001/api/stock?id=1"
```

---

### 5. Obter Produto por ID

```bash
curl http://localhost:3001/api/products/1
```

---

### 6. Registrar Novo Usuário

```bash
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "novo@example.com",
    "password": "senha123",
    "name": "Novo Usuário"
  }'
```

**Resposta esperada (201):**
```json
{
  "message": "Usuário criado com sucesso",
  "user": {
    "id": 2,
    "email": "novo@example.com",
    "name": "Novo Usuário",
    "role": "user"
  }
}
```

---

### 7. Login (Admin Padrão)

```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin123"
  }'
```

**Resposta esperada (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "admin@example.com",
    "name": "Administrador",
    "role": "admin"
  }
}
```

**⚠️ IMPORTANTE:** Copie o token para usar nos próximos testes!

---

### 8. Definir Estoque Absoluto (PUT) - Admin

Substitua `SEU_TOKEN_AQUI` pelo token obtido no login:

```bash
curl -X PUT http://localhost:3001/api/products/1/stock \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -d '{
    "stock": 100
  }'
```

**Resposta esperada (200):**
```json
{
  "id": 1,
  "sku": "CASE-IPHN",
  "stock": 100
}
```

**Erro sem token (401):**
```json
{
  "error": "Token de acesso não fornecido"
}
```

---

### 9. Ajustar Estoque (PATCH) - Admin

```bash
curl -X PATCH http://localhost:3001/api/products/1/stock \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -d '{
    "delta": -5
  }'
```

**Resposta esperada (200):**
```json
{
  "id": 1,
  "sku": "CASE-IPHN",
  "stock": 95
}
```

**Erro se estoque insuficiente (400):**
```json
{
  "error": "Estoque insuficiente"
}
```

---

### 10. Acessar Swagger UI

Abra no navegador:
```
http://localhost:3001/api/docs
```

Aqui você pode:
- Ver todos os endpoints documentados
- Testar diretamente na interface
- Ver exemplos de requisição/resposta

---

### 11. Listar Produtos (HTML)

```bash
curl -H "Accept: text/html" http://localhost:3001/api/products
```

Retorna uma página HTML formatada com tabela dos produtos.

---

## 🔐 Testando Autenticação e Segurança

### Teste 1: Endpoint protegido sem token

```bash
curl -X PUT http://localhost:3001/api/products/1/stock \
  -H "Content-Type: application/json" \
  -d '{"stock": 50}'
```

**Deve retornar 401 (Unauthorized)**

---

### Teste 2: Endpoint protegido com token inválido

```bash
curl -X PUT http://localhost:3001/api/products/1/stock \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token-invalido" \
  -d '{"stock": 50}'
```

**Deve retornar 403 (Forbidden)**

---

### Teste 3: Usuário comum tentando atualizar estoque

1. Crie um usuário comum (role: "user")
2. Faça login e obtenha o token
3. Tente atualizar estoque

**Deve retornar 403 (Acesso negado. Apenas administradores)**

---

## 📊 Sequência de Teste Completa

Execute na ordem:

1. ✅ Healthcheck
2. ✅ Listar produtos
3. ✅ Consultar estoque
4. ✅ Registrar usuário
5. ✅ Login (admin)
6. ✅ Atualizar estoque (PUT)
7. ✅ Ajustar estoque (PATCH)
8. ✅ Verificar produto atualizado
9. ✅ Testar acesso negado sem token
10. ✅ Acessar Swagger UI

---

## 🐛 Solução de Problemas

### API não responde

```bash
# Verifique se está rodando
docker compose ps

# Ver logs
docker compose logs -f
```

### Token expirado

- Tokens expiram em 24h por padrão
- Faça login novamente para obter novo token

### Erro 500 ao criar usuário

- Verifique se o banco está criado
- Verifique logs do Docker

---

## 📚 Mais Informações

- **Documentação Swagger**: `http://localhost:3001/api/docs`
- **README**: Ver `backend/README.md`
- **Código fonte**: Ver pasta `backend/src/`

---

## ✅ Checklist de Testes

- [ ] Healthcheck funciona
- [ ] Listar produtos funciona
- [ ] Consultar estoque funciona
- [ ] Registrar usuário funciona
- [ ] Login funciona
- [ ] Token JWT é retornado
- [ ] Atualizar estoque requer autenticação
- [ ] Apenas admin pode atualizar estoque
- [ ] Swagger UI está acessível
- [ ] Erros são retornados corretamente (401, 403, 404)

---

**Boa sorte nos testes! 🚀**

