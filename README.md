# DevOps Mini Blog (Node.js + MongoDB + GenAI)


This project is a small, deployable demo that shows End-to-End DevOps using Docker + Terraform + GitHub Actions (OIDC) on AWS.


Features:
- Express.js mini-blog (`/`, `/posts`, `/api/posts`)
- Optional AI assistant that uses OpenAI
- MongoDB (M0 free cluster)
- Deploy to **1 x t3.micro EC2** (free-tier) using Terraform with the Docker Container.
- CI/CD: GitHub Actions

---

## Quick local run (dev)
1. `cd app`
2. Create a `.env` and create an API Key with `https://openrouter.ai/` and populate it.
3. Run `docker compose up --build`
4. Visit `http://localhost:3000`
   - You can create posts which will be in your MongoDB
   - The Visits are also a collection in your MongoDB
   - You have an AI assistant that can help with your DevOps Projects (or anything you want)


---