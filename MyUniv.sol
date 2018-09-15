pragma solidity ^0.4.18;

interface ERC721 {
    
    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved,
    uint256 _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, 
    bool _approved);
    
    
    //change public to external due to interface
    
    function balanceOf(address _owner) external view returns (bool _balance);
    function ownerOf(uint256 _tokenId) external view returns (address _owner);
    function approve(address _to, uint256 _tokenId) external;
    function getApproved(uint256 _tokenId) external view returns (address _operator);

    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}
contract Student20{
    using SafeMath for uint;
    
    address manage = 0xed40a32e61a261c33890a04c6e34373af4d85cf6;
    uint internal _totalSupply;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }
    function transfer_S(address _to, uint tokens) public returns (bool success) {
        require(tokens >= 0);
        require(_to != address(0));
        if(_to != manage){
            balances[msg.sender] = balances[msg.sender] - tokens;
            balances[_to] = balances[_to] + tokens;
        }
        else{
            balances[msg.sender] = balances[msg.sender] - tokens;
            _totalSupply -= tokens;
        }
        Transfer(msg.sender, _to, tokens);
        return true;
    }
    function transferFrom_S(address _from, address _to, uint256 tokens) public returns(bool){
        require(tokens >= 0 && tokens <= balances[_from]);
        require(_from != address(0) && _to != address(0));
        if(_to == manage){
            balances[_from] = balances[_from] - tokens;
            allowed[_from][msg.sender] = allowed[_from][msg.sender] - tokens;
            _totalSupply -= tokens;
        }
        else{
            balances[_from] = balances[_from] - tokens;
            allowed[_from][msg.sender] = allowed[_from][msg.sender] - tokens;
            balances[_to] = balances[_to] + tokens;
        }
        Transfer(_from, _to, tokens);
        return true;
    }
    function approve(address spender, uint tokens) public returns (bool) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }
    function allowance(address tokenOwner, address spender) public view returns (uint) {
        return allowed[tokenOwner][spender];
    }
    function distribute(address _to, uint256 tokens) public returns (bool){
        require(tokens >= 0);
        require(_to != address(0) && _to != manage);
        //require(msg.sender == manage);
        _totalSupply += tokens;
        balances[_to] += (tokens);
        Distribute(_to, tokens);
        return true;
    }
    
    event Distribute(address indexed _to, uint tokens);
    event Transfer(address indexed _from, address indexed _to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}
contract MyUniv721 is ERC721{
    using SafeMath for uint256;
    
    address internal creator = msg.sender;
    uint256 internal maxId = 100000;
    uint256 CurrentSupply = 0;
    mapping(address => bool) internal balances;
    mapping(uint256 => address) public tokenOwners;
    mapping(address => uint256) public ownerTokens;
    mapping(uint256 => string) public tokenData;
    mapping(uint256 => address) internal allowance;
    mapping(address => mapping(address => bool)) internal authorised;
    
    function TotalSupply() public view returns (uint256) {
        return CurrentSupply;
    }
    function isValidToken(uint256 _tokenId) public view returns(bool){
        return (_tokenId != 0 && _tokenId <= maxId); 
    }
    
    function balanceOf(address _owner) public view returns(bool){
        require(_owner!=address(0));
        return balances[_owner];
    }
    
    function ownerOf(uint256 _tokenId) public returns(address) {
        require(isValidToken(_tokenId));
        if(tokenOwners[_tokenId] !=0x0){
            return tokenOwners[_tokenId];
        } else {
             tokenOwners[_tokenId] = creator;
            return creator;
        }
    }
    
    function isApprovedForAll(address _owner, address _operator) public view returns (bool){
        require(_owner != address(0) && _operator != address(0));
        return authorised[_owner][_operator];
    }
    
    function setApprovalForAll(address _operator, bool _approved) public {
        emit ApprovalForAll(msg.sender,_operator,_approved);
        authorised[msg.sender][_operator] = _approved;
    }
    
    function getApproved(uint256 _tokenId) public view returns (address){
        require(isValidToken(_tokenId));
        return allowance[_tokenId];
    }
    
    function approve(address _approved, uint256 _tokenId) public{
        address owner = ownerOf(_tokenId);
        require( owner == msg.sender    //Require Sender Owns Token
            || authorised[owner][msg.sender]    //  save gas then isApproved4R
        );
        emit Approval(owner, _approved, _tokenId);
        allowance[_tokenId] = _approved;
    }
    modifier CreatOnly{
        require(msg.sender == creator);
        _;
    }
    function distribute(address Newowner_ad, 
        uint256 _tokenId, 
        string data)                        // Student_ID 배포
        external returns (uint256){
        require(Newowner_ad != address(0));
        CurrentSupply += 1;
        tokenOwners[_tokenId] = Newowner_ad;
        balances[Newowner_ad] = true;
        ownerTokens[Newowner_ad] = _tokenId;
        tokenData[_tokenId] = data;
        return CurrentSupply;
    }
    function removeFromTokenList(address owner_ad, uint256 _tokenId) CreatOnly public {
            require(owner_ad != address(0));
            require(ownerOf(_tokenId) == owner_ad);
            balances[owner_ad] = false;
            ownerTokens[owner_ad] = 0;
            tokenOwners[_tokenId] = creator;
    }
     function ownership(address owner_ad) public returns (uint256){  // owner's ID
        require(owner_ad != address(0));
        require(balances[owner_ad]);
        return ownerTokens[owner_ad];
    }
    function ownerdata(address owner_ad) public returns (string){   // owner's Data
        require(owner_ad != address(0));
        require(balances[owner_ad]);
        return tokenData[ownerTokens[owner_ad]];
    }
    function tokenMetadata(uint256 _tokenId) public returns (string) {
        require(isValidToken(_tokenId));
        return tokenData[_tokenId];
    }
}
contract Ballot is MyUniv721{
    struct Voter{
        bool voted;
        bool approve;
        uint256 vote_index;
        address Student_ID;
    }
    struct Proposal {
        bytes32 name; 
        uint256 Count;
    }
    
    mapping(address => Voter) public voters;
    Proposal[] public proposals; 
    modifier chaironly{
        //require(ownership(msg.sender) == 1);
        _;
    }
    function MakeVote(bytes32[] proposalNames) chaironly public {
        for (uint256 i = 1; i <= proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                Count: 0
            }));
        }
    }
    function giveRightToVote(address voter) chaironly public {
        require(!voters[voter].voted && !voters[voter].approve);
        voters[voter].approve = true;
    }
    function vote(uint256 proposal) public {
        require(proposal > 0 && proposal <= proposals.length);
        Voter storage sender = voters[msg.sender];
        require(balanceOf(sender.Student_ID));
        require(!sender.voted);
        sender.voted = true;
        sender.vote_index = proposal;
        proposals[proposal].Count += 1;
    }
    function ResultofVote() chaironly public view returns (bytes32){
        uint256 max = 0;
        uint256 result;
        for (uint256 i = 1; i <= proposals.length; i++) {
            if (proposals[i].Count > max) {
                max = proposals[i].Count;
                result = i;
            }
        }
        bytes32 selected = proposals[result].name;
        delete proposals;
        return selected;
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, 
    // but the benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}