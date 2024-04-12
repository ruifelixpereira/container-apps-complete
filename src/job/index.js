const axios = require('axios');

const url = process.env.URL || "https://reqres.in/api/users?page=2";

async function main() {  

    console.log('URL:', url);

    try {
        const res = await axios({
            method: 'get',
            url: url,
            params: {
                _limit: 5,
            },
        });
        console.log(res);
    } catch (e) {
        console.log(e);
    }
}

main();  
