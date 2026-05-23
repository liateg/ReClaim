import axios from 'axios';

async function test() {
  try {
    const res = await axios.post('http://127.0.0.1:3000/auth/login', {
      email: 'ruthdagim307@gmail.com',
      password: 'any'
    });
    console.log('SUCCESS:', res.data);
  } catch (err) {
    if (err.response) {
      console.log('ERROR:', err.response.status, err.response.data);
    } else {
      console.log('FAILED:', err.message);
    }
  }
}

test();
