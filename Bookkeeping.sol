// SPDX-License-Identifier: MIT

//Contrato inteligente para a escrituração zootécnica.

pragma solidity ^0.8.0;

contract Bookkeeping {
    // Struct para armazenar informações do produtor
    struct Productor {
        uint256 id;
        string name;
        string email;
        string telephone;
        address localization;
    }
    
    // Struct para armazenar informações do animal
    struct Animal {
        address productor;
        uint256 code;
        uint256 weight;
        uint256 birthday;
        uint256 pregnancyPercentage;
        uint256 natalIndex;
        uint256 mortalIndex;
    }

    // Endereço do dono do contrato
    address public owner;
    // Lista de endereços de produtores
    address[] public productorList;
    // Lista de endereços de animais
    address[] public animalList;

    // Mapeamento para armazenar informações dos produtores
    mapping(address => Productor) public productors;
    // Mapeamento para armazenar informações dos animais
    mapping(address => Animal) public animals;

    // Mapeamento para controlar permissões de acesso entre endereços
    mapping(address => mapping(address => bool)) public isApproved;
    // Mapeamento para controlar se um endereço é um produtor
    mapping(address => bool) public isProductor;
    // Mapeamento para controlar se um endereço é um animal
    mapping(address => bool) public isAnimal;

    // Contadores para o número total de produtores, animais e permissões concedidas
    uint256 public productorCount = 0;
    uint256 public animalCount = 0;
    uint256 public permissionGrantedCount = 0;

    // Eventos para notificar alterações no contrato
    event ProductorAdded(address indexed productorAddress);
    event AnimalAdded(address indexed animalAddress, address indexed productorAddress);
    event PermissionGranted(address indexed from, address indexed to);
    event PermissionRevoked(address indexed from, address indexed to);

    // Função construtora que define o dono do contrato
    constructor() {
        owner = msg.sender;
    }

    // Função para registrar detalhes do produtor
    function setDetails(uint256 _id, string memory _name, string memory _email, string memory _telephone, address _localization) public {
        require(!isProductor[msg.sender]);

        Productor storage p = productors[msg.sender];

        p.id = _id;
        p.name = _name;
        p.email = _email;
        p.telephone = _telephone;
        p.localization = _localization;

        productorList.push(msg.sender);
        isProductor[msg.sender] = true;
        isApproved[msg.sender][msg.sender] = true;
        productorCount++;
    }

    // Função para editar detalhes do produtor
    function editDetails(string memory _email, string memory _telephone, address _localization) public {
        require(isProductor[msg.sender]);

        Productor storage p = productors[msg.sender];
        p.email = _email;
        p.telephone = _telephone;
        p.localization = _localization;
    }
    
    // Função para registrar um novo animal
    function setAnimal(uint256 _code, uint256 _weight, uint256 _birthday, uint256 _pregnancyPercentage, uint256 _natalIndex, uint256 _mortalIndex, address _productor) public {
        require(!isAnimal[msg.sender]);

        Animal storage a = animals[msg.sender];

        a.code = _code;
        a.weight = _weight;
        a.birthday = _birthday;
        a.pregnancyPercentage = _pregnancyPercentage;
        a.natalIndex = _natalIndex;
        a.mortalIndex = _mortalIndex;
        a.productor = _productor;

        animalList.push(msg.sender);
        isAnimal[msg.sender] = true;
        animalCount++;

        emit AnimalAdded(msg.sender, msg.sender);
    }

    // Função para editar informações de um animal
    function editAnimal(uint256 _weight, uint256 _birthday, uint256 _pregnancyPercentage, uint256 _natalIndex, uint256 _mortalIndex) public {
        require(isAnimal[msg.sender]);

        Animal storage a = animals[msg.sender];

        a.weight = _weight;
        a.birthday = _birthday;
        a.pregnancyPercentage = _pregnancyPercentage;
        a.natalIndex = _natalIndex;
        a.mortalIndex = _mortalIndex;
    }

    // Função para conceder permissão de acesso a outro endereço
    function givePermission(address _localization) public returns(bool sucess){
        isApproved[msg.sender][_localization] = true;
        permissionGrantedCount++;
        return true;
    }

    // Função para revogar permissão de acesso de outro endereço
    function revokePermission(address _localization) public returns(bool success){
        isApproved[msg.sender][_localization] = false;
        return true;
    }

    // Função para obter a lista de produtores
    function getProductors() public view returns(address[] memory){
        return productorList;
    }

    // Função para obter a lista de animais
    function getAnimals() public view returns(address[] memory){
        return animalList;
    }

    // Função para buscar informações de um produtor
    function searchProductorData(address _address) public view returns(uint256, string memory, string memory, string memory, address){
        require(isApproved[_address][msg.sender]);

        Productor storage p = productors[_address];

        return (p.id, p.name, p.email, p.telephone, p.localization);
    }

    // Função para buscar informações de um animal
    function searchAnimalData(address _address) public view returns(address, uint256, uint256, uint256, uint256, uint256, uint256){
        require(isApproved[_address][msg.sender]);

        Animal storage a = animals[_address];

        return (a.productor, a.code, a.weight, a.birthday, a.pregnancyPercentage, a.natalIndex, a.mortalIndex);
    }

    // Função para buscar informações de contabilidade de um endereço de produtor
    function searchBookkeeping(address _address) public view returns(uint) {
        Productor storage p = productors[_address];

        return (p.id);
    }

    // Função para obter o número total de produtores
    function getProductorCount() public view returns(uint256) {
        return productorCount;
    }

    // Função para obter o número total de animais
    function getAnimalCount() public view returns(uint256) {
        return animalCount;
    }
}
