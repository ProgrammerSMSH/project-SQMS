const http = require('http');

const post = (path, data) => {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 5000,
      path: `/api/v1/user/auth${path}`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => resolve({ status: res.statusCode, data: JSON.parse(body) }));
    });

    req.on('error', reject);
    req.write(JSON.stringify(data));
    req.end();
  });
};

async function test() {
  try {
    console.log('Testing Register...');
    const reg = await post('/register', { 
      name: 'Tester', 
      email: `test_${Date.now()}@sqms.com`, 
      password: 'pass' 
    });
    console.log('Register Response:', reg);

    console.log('\nTesting Login...');
    const login = await post('/login', { 
      email: 'test@sqms.com', // Using a known email if register fails or just use the new one
      password: 'pass' 
    });
    console.log('Login Response:', login);
  } catch (e) {
    console.error('Test Failed:', e);
  }
}

test();
