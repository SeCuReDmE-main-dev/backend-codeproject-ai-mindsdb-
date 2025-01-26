document.addEventListener('DOMContentLoaded', () => {
    const runPythonButton = document.getElementById('run-python');
    const runJavascriptButton = document.getElementById('run-javascript');
    const runOtherButton = document.getElementById('run-other');

    runPythonButton.addEventListener('click', () => {
        const pythonCode = document.getElementById('python-code').value;
        runCode('python', pythonCode);
    });

    runJavascriptButton.addEventListener('click', () => {
        const javascriptCode = document.getElementById('javascript-code').value;
        runCode('javascript', javascriptCode);
    });

    runOtherButton.addEventListener('click', () => {
        const otherCode = document.getElementById('other-code').value;
        runCode('other', otherCode);
    });

    function runCode(language, code) {
        fetch(`http://localhost:5000/run_code`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ language, code })
        })
        .then(response => response.json())
        .then(data => {
            console.log(data);
            alert(`Output: ${data.output}`);
        })
        .catch(error => {
            console.error('Error:', error);
            alert('An error occurred while running the code.');
        });
    }
});
