document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('ai-form');
  const resultBox = document.getElementById('ai-result');
  const promptInput = document.getElementById('prompt');

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    const prompt = promptInput.value.trim();
    if (!prompt) {
      resultBox.innerHTML = '<p class="error">Please enter a prompt.</p>';
      return;
    }

    resultBox.innerHTML = '<p><em>🤔 Thinking...</em></p>';

    try {
      const res = await fetch('/api/ai', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt }),
      });

      const data = await res.json();
      let text = data.text || '';

      text = text
        .replace(/\\n/g, '\n')
        .replace(/\\u003C/g, '<')
        .replace(/\\u003E/g, '>')
        .replace(/\\"/g, '"');

      resultBox.className = 'ai-output';
      resultBox.innerHTML = marked.parse(text);
    } catch (err) {
      console.error('❌ Fetch failed:', err);
      resultBox.innerHTML = '<p class="error">❌ Failed to fetch response.</p>';
    }
  });
});
