// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import {ERC721Base} from "./ERC721Base.sol";

interface ILibraryStorage {
    function readLibraryBetweenChunks(
        string calldata libraryName,
        uint256 startChunk,
        uint256 endChunk
    ) external view returns (string memory lib);

    function readLibrary(string calldata libraryName)
        external
        view
        returns (string memory lib);
}

/// @author zkmc.eth
/// @title  Frame NFT
contract Frame is ERC721Base {
    struct StorageCall {
        string key;
        uint256 from;
        uint256 to;
        uint256 storageAddressIndex;
    }

    mapping(uint256 => StorageCall) public storageCalls;
    uint256 storageCallsCount;
    mapping(uint256 => ILibraryStorage) public storages;

    bool public initSuccess = false;

    /**
      Initialize
    */
    constructor() ERC721Base("Frame NFT", "FRAME", 0.1 ether, 10_000) {}

    function init(
        StorageCall[] calldata _calls,
        ILibraryStorage[] calldata _storages
    ) public {
        require(!initSuccess, "Frame: Can't re-init contract");

        _setCalls(_calls);
        _setStorages(_storages);

        initSuccess = true;
    }

    /**
      Internals
    */

    function _setCalls(StorageCall[] calldata _calls) internal {
        for (uint256 sx; sx < _calls.length; sx++) {
            storageCalls[sx] = _calls[sx];
        }
        storageCallsCount = _calls.length;
    }

    function _setStorages(ILibraryStorage[] calldata _storages) internal {
        for (uint256 sx; sx < _storages.length; sx++) {
            storages[sx] = _storages[sx];
        }
    }

    /**
      Mint
    */
    function mint(uint256 numToBeMinted)
        external
        payable
        hasExactPayment(numToBeMinted)
        withinMintLimit(4, numToBeMinted)
    {
        _mintMany(_msgSender(), numToBeMinted);
    }

    /**
      Render
    */
    function tokenURI() public view returns (string memory) {
        string memory result = "data:text/html,";

        for (uint256 sx; sx < storageCallsCount; sx++) {
            result = string.concat(
                result,
                storages[storageCalls[sx].storageAddressIndex]
                    .readLibraryBetweenChunks(
                        storageCalls[sx].key,
                        storageCalls[sx].from,
                        storageCalls[sx].to
                    )
            );
        }
        return result;
    }
}
