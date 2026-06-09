#!/bin/bash
# Migrate C25 Swarm Plugin v1 → v2

echo "🔄 Migrating C25 Swarm Plugin to v2.0..."

# Backup existing
if [[ -f ~/aimetaverse_swarm.py ]]; then
  cp ~/aimetaverse_swarm.py ~/aimetaverse_swarm.py.v1.bak
  echo "✅ Backed up v1: ~/aimetaverse_swarm.py.v1.bak"
fi

# Install dependencies
echo "📦 Installing dependencies..."
pip install requests aiosqlite --break-system-packages 2>/dev/null || pip install requests aiosqlite 2>/dev/null || true

# Copy upgraded plugin
if [[ -f ~/.c25_upgrade/aimetaverse_swarm_v2.py ]]; then
  cp ~/.c25_upgrade/aimetaverse_swarm_v2.py ~/aimetaverse_swarm.py
  chmod +x ~/aimetaverse_swarm.py
  echo "✅ Upgraded plugin installed"
else
  echo "❌ Upgraded plugin not found. Run the full upgrade script first."
  exit 1
fi

# Initialize database
echo "💾 Initializing database..."
python3 -c "
import sys
sys.path.insert(0, '~/.c25_db')
from c25_db import get_db
with get_db() as conn:
    print('✅ Database initialized at ~/.c25_db/c25_sovereign.db')
"

# Test LLM providers
echo "🔌 Testing LLM providers..."
python3 << 'TESTLLM'
import asyncio, sys, os
sys.path.insert(0, os.path.expanduser("~/.c25_llm/providers"))
from qwen_local import QwenLocalProvider, LLMConfig

async def test_local():
    config = LLMConfig(provider='qwen_local', model='qwen2.5-coder:7b')
    llm = QwenLocalProvider(config)
    result = await llm.generate("Hello, Constellation25!", system="You are a helpful AI.")
    print(f"✅ Local Qwen test: {'success' if result.success else 'failed'}")
    if result.success:
        print(f"   Response: {result.content[:100]}...")

asyncio.run(test_local())
TESTLLM

echo ""
echo "========================================="
echo "✅ MIGRATION COMPLETE"
echo "========================================="
echo ""
echo "🚀 To use upgraded swarm:"
echo "  # With real LLMs (provide API keys):"
echo "  python3 ~/aimetaverse_swarm.py login --user cygel --provider claude --api-key YOUR_KEY"
echo "  python3 ~/aimetaverse_swarm.py swarm --user cygel --prompt 'Create CMakeLists.txt' --formats .md .cmake"
echo ""
echo "  # With local Qwen only (offline):"
echo "  python3 ~/aimetaverse_swarm.py swarm --user cygel --prompt 'Test' --providers qwen_local --local-fallback"
echo ""
echo "  # With multi-agent coordination:"
echo "  python3 ~/aimetaverse_swarm.py swarm --user cygel --prompt 'Complex task' --coordination"
echo ""
echo "📊 To query execution history:"
echo "  python3 ~/aimetaverse_swarm.py history --user cygel --limit 10"
echo ""
echo "🔗 Agent mesh is now active - agents can coordinate on complex tasks!"
echo "========================================="
