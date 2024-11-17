// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MemeCoinSecurityEcosystem {
    address public owner;
    uint256 public totalFunds;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    enum ProjectStatus { Pending, Approved, Funded, Completed }
    
    struct Expert {
        address expertAddress;
        string name;
        string expertiseArea;
        bool isVerified;
    }

    struct Project {
        uint256 id;
        string title;
        address creator;
        uint256 fundsNeeded;
        uint256 fundsRaised;
        ProjectStatus status;
    }

    struct Investor {
        address investorAddress;
        uint256 amountInvested;
    }

    mapping(address => Expert) public experts;
    mapping(uint256 => Project) public projects;
    mapping(uint256 => Investor[]) public projectInvestors;
    
    uint256 public projectCount;
    
    event ExpertAdded(address indexed expertAddress, string name, string expertiseArea);
    event ProjectCreated(uint256 indexed projectId, string title, uint256 fundsNeeded);
    event FundsReceived(uint256 indexed projectId, address indexed investor, uint256 amount);
    event ProjectFunded(uint256 indexed projectId);
    event FundsDeposited(address indexed from, uint256 amount);
    
    constructor() {
        owner = msg.sender;
    }

    // Add a new expert to the ecosystem
    function addExpert(address _expertAddress, string memory _name, string memory _expertiseArea) public onlyOwner {
        require(!experts[_expertAddress].isVerified, "Expert already verified.");
        
        experts[_expertAddress] = Expert({
            expertAddress: _expertAddress,
            name: _name,
            expertiseArea: _expertiseArea,
            isVerified: true
        });
        
        emit ExpertAdded(_expertAddress, _name, _expertiseArea);
    }

    // Create a new project for funding
    function createProject(string memory _title, uint256 _fundsNeeded) public {
        require(_fundsNeeded > 0, "Funding needed must be greater than zero.");
        
        projectCount++;
        projects[projectCount] = Project({
            id: projectCount,
            title: _title,
            creator: msg.sender,
            fundsNeeded: _fundsNeeded,
            fundsRaised: 0,
            status: ProjectStatus.Pending
        });
        
        emit ProjectCreated(projectCount, _title, _fundsNeeded);
    }

    // Invest in a project
    function investInProject(uint256 _projectId) public payable {
        Project storage project = projects[_projectId];
        require(project.status == ProjectStatus.Pending, "Project is not open for funding.");
        require(msg.value > 0, "Investment must be greater than zero.");
        
        project.fundsRaised += msg.value;
        projectInvestors[_projectId].push(Investor(msg.sender, msg.value));
        
        emit FundsReceived(_projectId, msg.sender, msg.value);
        
        if (project.fundsRaised >= project.fundsNeeded) {
            project.status = ProjectStatus.Funded;
            emit ProjectFunded(_projectId);
        }
    }

    // Deposit funds to the owner’s address
    function depositFunds() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero.");
        totalFunds += msg.value;
        
        emit FundsDeposited(msg.sender, msg.value);
    }

    // Withdraw funds for a funded project
    function withdrawFunds(uint256 _projectId) public {
        Project storage project = projects[_projectId];
        require(project.creator == msg.sender, "Only the project creator can withdraw funds.");
        require(project.status == ProjectStatus.Funded, "Project is not fully funded.");

        uint256 amount = project.fundsRaised;
        project.fundsRaised = 0;
        project.status = ProjectStatus.Completed;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed.");
    }

    // Get project details
    function getProject(uint256 _projectId) public view returns (Project memory) {
        return projects[_projectId];
    }

    // Get expert details
    function getExpert(address _expertAddress) public view returns (Expert memory) {
        return experts[_expertAddress];
    }
}
