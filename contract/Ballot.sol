pragma solidity >=0.7.0 < 0.9.0

contract Ballot{
    //投票人  
    struct Voter{
        uint weight; //权重 
        bool voted;  // 是否已经投票过了
        address delegate; //被委托人  代理？
        uint vote;    //提案的索引
    }

    struct Proposal{
        bytes32 name; 
        uint voteCount;
    }

    address public chairPerson;
    mapping(address => Voter) public voters;  //hash表 存的是 投票人

    Proposal[] public proposals;   // 多个提案？  动态数组

    constructor(bytes32[] memory proposalNames){
        chairPerson = msg.sender;   
        voters[chairPerson].weight = 1;    // 主席
        for(uint i=0; i<proposalNames.length; i++){  //初始化每个提案 
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    // 只有主席才能调用这个方法  给投票人分配权重  投票人没有投票过  weight=0  才会分配权重 
    function giveRightToVote(address voter) external{
        require(msg.sender == chairPerson, "only chairperson can give right to vote");
        require(!voters[voter].voted, "the voter already voted");
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    // 被委托 ？  把你的投票权 给别人  to  
    function delegate(address to) external{
        Voter storage sender = voters[msg.sender]; 
        require(!sender.voted, "you already voted"); // 已经投票过了不能再委托了 
        require(to != msg.sender, "self-delegation is disallowed.") // 不能自己给自己委托 
        while(voters[to].delegate !=address(0)){  // to也可以委托给别人 那么msg.sender 委托给 to.delegate 
            to = voters[to].delegate;
            require(to != msg.sender, "found loop in delegation");
        }
        Voter storage delegate_ = voters[to];  //被委托人 
        require(delegate_.weight >-== 1);  
        sender.voted = true;
        sender.delegate = to;
        if(delegate_.voted){   //如果被委托人已经投票过了  
            proposals[delegate_.vote].voteCount += sender.weight; // 增加提案得票数 
        }else{
            delegate_.weight += sender.weight;  // 增加被委托人的权重  
        }
    }

    // 投票给提案 
    function vote(uint proposal) external{
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "already voted"); 
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;  // 增加提案的得票数 
    }

    //计算得票最多的提案  winningProposal_   为啥不用 _开头 ？ 
    function winningProposal() external view returns (uint winningProposal_){
        uint maxCount = 0;
        for(uint p=0; p<proposals.length; p++){
            if(proposals[p].voteCount > maxCount ){
                maxCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function winnername() public view returns (bytes32 winnername_){
        winnername_ = proposals[winningProposal()].name;
    }
}