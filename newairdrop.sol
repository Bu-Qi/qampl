// SPDX-License-Identifier: SimPL-2.0
pragma solidity  ^0.7.6;

interface IQkswapV2Pair {
    function sync() external;
}
interface  token {
    function balanceOf(address owner) external view returns (uint);
}
interface IQkswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}
/**
 * 持有qa账号，给这个合约授权，然后调用空投合约。
 */
contract qampl_airdrop is SafeMath{

    address public owner;
    address qampl_address = 0xa9ad3421c8953294367D3B2f6efb9229C690Cacb;
    uint Last_airdrop_time = 0;

    address[] public  qkswap_Pairs;

    constructor() {
        owner = msg.sender;
    }
    //需要管理员授权自己的qa给合约
    //仅容许管理员可以触发空投合约
    function airdrop() public {
        require(block.timestamp - Last_airdrop_time >= 86400);
        require(msg.sender == owner);
        for(uint i;i<qkswap_Pairs.length;i++)
        {
            //给USDT对空投1.2%持有量，其他交易对1%
            if(qkswap_Pairs ==0x7439da46526de466c72e67e26e9ab363d7731b22)
        {
            uint airdrop_qampl = token(qampl_address).balanceOf(0x7439da46526de466c72e67e26e9ab363d7731b22)/83;
        }
           else if (qkswap_Pair !=0x7439da46526de466c72e67e26e9ab363d7731b22)
           {
            uint airdrop_qampl = token(qampl_address).balanceOf(qkswap_Pairs[i])/100;
            }
            safeTransferFrom(qampl_address,owner,qkswap_Pairs[i],airdrop_qampl);

            //刷新流动池的余额
            IQkswapV2Pair pair = IQkswapV2Pair(qkswap_Pairs[i]);
            pair.sync();
        }
        Last_airdrop_time = block.timestamp;
    }

    

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    function setOwner(address payable new_owner) public {
        require(msg.sender == owner);
        owner = new_owner;
    }
     //设置一个值只有池子里的值大于这个值才能加进空投的范围之内
    function setRequire_qampl(uint _value) public{
        require(msg.sender == owner);
        require_qampl = _value;
    }
    //传入一个新的token地址，这个地址需要在qkswap里面有交易对
    function add_qkswap_Pair(address new_token) public {
        if(msg.sender != owner)revert();
        
        address Pair_address = IQkswapV2Factory(0x4cB5B19e8316743519072170886355B0e2C717cF).getPair(qampl_address, new_token) 
        require(token(qampl_address).balanceOf(Pair_address) > require_qampl );
        for(uint i;i<qkswap_Pairs.length;i++)
        {
            require(qkswap_Pairs[i] != Pair_address);
        }
        qkswap_Pairs.push(Pair_address);
        

        //刷新流动池的余额
        IQkswapV2Pair pair = IQkswapV2Pair(Pair_address);
        pair.sync();
    }
    
    function Pair_amount() public view returns (uint amount){
        return qkswap_Pairs.length;
    }
}
