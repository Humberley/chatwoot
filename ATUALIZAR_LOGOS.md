# 🎨 Como Atualizar Logos e Imagens

## 📁 Localização das Imagens

As logos do InovaChat ficam em:
```
public/brand-assets/
├── logo.svg              # Logo normal (modo claro)
├── logo_dark.svg         # Logo modo escuro
├── logo_thumbnail.svg    # Favicon/ícone
```

---

## 🔄 Passo a Passo para Atualizar

### 1️⃣ **Substituir as Imagens Localmente (Windows)**

Coloque suas novas logos em `public/brand-assets/`:

```bash
# Suas imagens devem ter esses nomes exatos:
public/brand-assets/logo.svg
public/brand-assets/logo_dark.svg
public/brand-assets/logo_thumbnail.svg
```

**Dica:** Mantenha o formato SVG para qualidade em qualquer tamanho!

---

### 2️⃣ **Commit e Push**

```bash
git add public/brand-assets/
git commit -m "Update: Novas logos InovaChat"
git push origin main
```

---

### 3️⃣ **Na VPS: Atualizar**

```bash
cd ~/chatwoot
git pull origin main

# Restart para aplicar (importante!)
docker service update --force inovachat_inovachat_app
```

**⏰ Aguarde ~30 segundos** para o serviço reiniciar.

---

### 4️⃣ **Limpar Cache do Navegador**

Pressione `Ctrl + Shift + R` ou `Cmd + Shift + R`

**Pronto!** As novas logos devem aparecer! 🎉

---

## 🔍 Se as logos não aparecerem:

### **1. Verificar se os arquivos estão no container:**

```bash
docker exec $(docker ps -qf "name=inovachat_inovachat_app") ls -la /app/public/brand-assets/
```

Deve mostrar seus arquivos.

---

### **2. Verificar se o volume está montado:**

```bash
docker service inspect inovachat_inovachat_app --format '{{json .Spec.TaskTemplate.ContainerSpec.Mounts}}' | jq
```

Deve mostrar o mount de `./public/brand-assets`.

---

### **3. Forçar restart novamente:**

```bash
docker service update --force inovachat_inovachat_app
```

---

### **4. Verificar permissões dos arquivos:**

```bash
# No Windows, verificar se os arquivos estão no Git
git status public/brand-assets/

# Na VPS, verificar se git pull baixou
cd ~/chatwoot
ls -la public/brand-assets/
```

---

## 📐 Tamanhos Recomendados

| Arquivo | Tamanho Recomendado | Uso |
|---------|---------------------|-----|
| `logo.svg` | 200x50px aprox | Header, login, etc. |
| `logo_dark.svg` | 200x50px aprox | Header modo escuro |
| `logo_thumbnail.svg` | 512x512px | Favicon, ícone app |

**Dica:** SVG escala perfeitamente, então os tamanhos são flexíveis.

---

## 🎨 Favicon (ícone da aba do navegador)

O favicon usa `logo_thumbnail.svg`. Se quiser usar PNG:

1. Crie um `favicon.png` (512x512px)
2. Coloque em `public/`
3. Commit e push
4. Restart

---

## 🖼️ Outros Assets

Se quiser customizar outras imagens:

```bash
# Dashboard backgrounds, ícones, etc.
public/
├── brand-assets/        # Logos principais
├── packs/              # Assets compilados (não editar)
└── [outras imagens]    # Pode adicionar aqui
```

Para incluir no container, adicione volume no docker-compose:

```yaml
volumes:
  - ./public/minha-pasta:/app/public/minha-pasta
```

---

## ⚡ Atalho Rápido

```bash
# Depois de trocar as logos localmente:
git add public/brand-assets/ && git commit -m "Update logos" && git push

# Na VPS:
cd ~/chatwoot && git pull && docker service update --force inovachat_inovachat_app
```

**Ctrl + Shift + R no navegador e pronto!** ✅

---

## 🔄 Reverter para Logos Antigas

```bash
# Restaurar do Git
git checkout HEAD~1 public/brand-assets/
git push

# Na VPS
cd ~/chatwoot && git pull && docker service update --force inovachat_inovachat_app
```

---

Simples assim! 🎨
