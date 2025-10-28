# 🚂 Railway One-Time Setup (2 Minutes)

## Current Issue
Your app can't connect to the database because `DATABASE_URL` is not set.

## Quick Fix (Follow These Steps)

### Step 1: Get Database Connection String
1. Go to: https://railway.app/dashboard
2. Open your project
3. Click on the **PostgreSQL** service (database icon)
4. Look for **"Variables"** or **"Connect"** tab
5. Find and **COPY** the value that looks like:
   ```
   postgresql://postgres:xxxx@monorail.proxy.rlwy.net:5432/railway
   ```

### Step 2: Add to Your App Service
1. Click on your **sengp-api** service (the Node.js app)
2. Click **"Variables"** tab
3. Click **"New Variable"**
4. Add:
   - **Variable**: `DATABASE_URL`
   - **Value**: [Paste the connection string]
5. Click **"Add"**

### Step 3: Wait for Auto-Deploy
- Railway automatically redeploys (30-60 seconds)
- Check the logs for: "✅ Database connected successfully"

### Step 4: Add Other Variables
While you're in Variables, add these too:

```
NODE_ENV = production
PORT = 3000
API_VERSION = v1
JWT_SECRET = [go to uuidgenerator.net and paste a UUID]
JWT_REFRESH_SECRET = [generate another UUID]
BCRYPT_ROUNDS = 10
```

## After Setup
✅ Every git push automatically deploys
✅ No manual steps needed
✅ Just code and push!

## Your App URL
After deployment succeeds:
- Click "Settings" → "Generate Domain"
- Your URL: `https://sengp-api-production.up.railway.app`

## Test It
Visit: `https://your-url.up.railway.app/health`

Should return: `{"success": true, "message": "Server is running"}`

---

**That's it!** One-time setup, then everything is automatic! 🚀
