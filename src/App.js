import React, { useState } from 'react';

function App() {
  const [output, setOutput] = useState('');
  const [isDeploying, setIsDeploying] = useState(false);

  const handleDeploy = async () => {
    setIsDeploying(true);
    setOutput('Starting deployment...\n');

    try {
      const response = await fetch('/deploy', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const reader = response.body.getReader();
      const decoder = new TextDecoder();

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value);
        setOutput(prev => prev + chunk);
      }
    } catch (error) {
      setOutput(prev => prev + `\nError: ${error.message}\n`);
    } finally {
      setIsDeploying(false);
    }
  };

  const clearOutput = () => {
    setOutput('');
  };

  return (
    <div style={{ 
      fontFamily: 'Arial, sans-serif', 
      maxWidth: '1200px', 
      margin: '0 auto', 
      padding: '20px' 
    }}>
      <header style={{ 
        textAlign: 'center', 
        marginBottom: '30px',
        borderBottom: '2px solid #eee',
        paddingBottom: '20px'
      }}>
        <h1 style={{ color: '#333', marginBottom: '10px' }}>
          GitLab Deployment Server
        </h1>
        <p style={{ color: '#666', fontSize: '16px' }}>
          Manual deployment interface
        </p>
      </header>

      <div style={{ marginBottom: '20px', textAlign: 'center' }}>
        <button
          onClick={handleDeploy}
          disabled={isDeploying}
          style={{
            backgroundColor: isDeploying ? '#ccc' : '#007bff',
            color: 'white',
            border: 'none',
            padding: '12px 24px',
            fontSize: '16px',
            borderRadius: '5px',
            cursor: isDeploying ? 'not-allowed' : 'pointer',
            marginRight: '10px',
            transition: 'background-color 0.3s'
          }}
        >
          {isDeploying ? 'Deploying...' : 'Deploy'}
        </button>
        
        <button
          onClick={clearOutput}
          disabled={isDeploying}
          style={{
            backgroundColor: '#6c757d',
            color: 'white',
            border: 'none',
            padding: '12px 24px',
            fontSize: '16px',
            borderRadius: '5px',
            cursor: isDeploying ? 'not-allowed' : 'pointer',
            transition: 'background-color 0.3s'
          }}
        >
          Clear Output
        </button>
      </div>

      <div style={{
        border: '1px solid #ddd',
        borderRadius: '5px',
        backgroundColor: '#f8f9fa'
      }}>
        <div style={{
          backgroundColor: '#e9ecef',
          padding: '10px',
          borderBottom: '1px solid #ddd',
          fontWeight: 'bold'
        }}>
          Deployment Output:
        </div>
        <pre style={{
          margin: '0',
          padding: '15px',
          backgroundColor: '#000',
          color: '#00ff00',
          fontFamily: 'Consolas, Monaco, monospace',
          fontSize: '14px',
          minHeight: '400px',
          maxHeight: '600px',
          overflow: 'auto',
          whiteSpace: 'pre-wrap',
          wordBreak: 'break-word'
        }}>
          {output || 'No deployment output yet. Click "Deploy" to start.'}
        </pre>
      </div>

      <footer style={{
        marginTop: '30px',
        textAlign: 'center',
        color: '#666',
        fontSize: '14px',
        borderTop: '1px solid #eee',
        paddingTop: '20px'
      }}>
        <p>Server running on port 3073</p>
      </footer>
    </div>
  );
}

export default App;
