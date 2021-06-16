const TRBGR = artifacts.require('./TRBGR.sol');
const  CataBoltSwap = artifacts.require('./CataBoltSwap.sol');

const toWei = (number) => web3.utils.toWei(number.toString());
const fromWei = (x) => web3.utils.fromWei(x);
const addr0 = "0x0000000000000000000000000000000000000000";
const burnAddress = "0x0000000000000000000000000000000000000001";
const bytes0 = "0x0000000000000000000000000000000000000000000000000000000000000000";

const transaction = (address, wei) => ({
    from: address,
    value: wei
});

const fail = (msg) => (error) => assert(false, error ?
    `${msg}, but got error: ${error.message}` : msg);

const revertExpectedError = async(promise) => {
    try {
        await promise;
        fail('expected to fail')();
    } catch (error) {
        assert(error.message.indexOf('revert') >= 0 || error.message.indexOf('invalid opcode') >= 0,
            `Expected revert, but got: ${error.message}`);
    }
}

const timeController = (() => {
    const addSeconds = (seconds) => new Promise((resolve, reject) => 
        web3.currentProvider.send({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [seconds],
            id: new Date().getTime()
        }, (error, result) => {
            web3.currentProvider.send({
                jsonrpc: '2.0', 
                method: 'evm_mine', 
                params: [], 
                id: new Date().getSeconds()
            }, (err, res) => resolve(res));
        }));
    

    const addDays = (days) => addSeconds(days * 24 * 60 * 60);
    const addHours = (hours) => addSeconds(hours * 60 * 60);

    const currentTimestamp = () => web3.eth.getBlock(web3.eth.blockNumber).timestamp;

    return {
        addSeconds,
        addDays,
        addHours,
        currentTimestamp
    };
})();

const ethBalance = (address) => web3.eth.getBalance(address);

contract('TRBGR Test', accounts => {

    const admin = accounts[1];
    const oneEth = toWei(1);

    const testAsync = async() => {
        const response = await new Promise(resolve => {
            setTimeout(() => {
            }, 1000);
        });
    }

    const createToken = () => TRBGR.new({ from: admin });
    const createSwap = (token) => CataBoltSwap.new(
        
        {from: admin}
    ); 
   //  it('initial burn', async() => {
   //      const token = await createToken();
   //      await token.excludeFromReward(burnAddress, {
   //          from: admin
   //      });
   //      await token.transfer(burnAddress, toWei("200000000000000"),{
   //          from: admin
   //      });
   //  });

   //  it('add liquidity', async() => {
   //      //const token = await TRBGR.at('0x6413b8ab6CF532069BAf7153b7FB5C3D32F0d2CC');
   //  });

   //  it('test swap', async() => {
   //      const token = await createToken();
   //      const swap = await createSwap(token.address);
   //      await token.transfer(swap.address, toWei(100 * 1000000000000), {
   //          from:admin
   //      });
   //      await swap.adminWhitelistUser(accounts[2], toWei(1000),{
   //          from:admin
   //      });

   //      await swap.swap({from:accounts[2], value:toWei(0.1)});
   // });

    it('test amount', async() => {
        //const token = await createToken();
        const swap = await createSwap(addr0);
        
        const amnt = await swap.amountOut(toWei(0.1));
        console.log(amnt.toString());
   });

});
