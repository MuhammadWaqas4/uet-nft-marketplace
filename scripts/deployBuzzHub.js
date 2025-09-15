const hre = require('hardhat');

async function verify(address, constructorArguments) {
    console.log(`verify  ${address} with arguments ${constructorArguments.join(',')}`);
    
    await hre.run('verify:verify', {
        address,
        constructorArguments
    });
}


async function main() {
     let string1 = "Bored Ape";
    let string2 = "Ape";

     await verify('0x56C23caE236FDeE535D7a8498C54C6c2b6049f5c', [string1,string2]);
}
main();