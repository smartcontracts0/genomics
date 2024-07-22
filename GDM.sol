/**
 *Submitted for verification at amoy.polygonscan.com on 2024-07-21
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: GDM.sol


pragma solidity ^0.8.20;





    interface ISequencedGenomicDataNFT{
        function mint(string memory _tokenURI, uint256 _parentID, address _owner) external returns (uint);
    }

contract FullAccessToken is ERC20, Ownable(msg.sender) {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {     
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}


contract GDM is ReentrancyGuard, Ownable(msg.sender){


    //**** Variables ****//

    IERC721 public RGDNFTSC; //This fixes the smart contract of raw nfts to prevent other smart contracts from interacting
    IERC721 public SGDNFTSC; //Same as Raw NFT SC
    address public RegistrationAuthority; //Repsonsible for registering eligible sequencing Centers
    address public LimitedAccessOracle; //This oracle is responsible for updating the number of operations for a buyer
    mapping(address => bool) public sequencingCenter; //A mapping of authorized sequencing centers
    uint256 public RGDNFTCount; //This is the RawNFTs number within the managment smart contract, not the NFT SC
    uint256 public SGDNFTCount; //This is the RawNFTs number within the managment smart contract, not the NFT SC
    ISequencedGenomicDataNFT public SequencedGenomicDataNFT;
    //FullAccessToken public FAT;

    //RGDNFT Variables//
    struct RGDNFT{
        uint256 RawNFTId; //a counter within the SC only
        IERC721 nft; //Necessary to enable transferring nfts when called later on
        uint256 tokenId; 
        address payable dataOwner;
    }

    //Method number => price/cost
    mapping(uint256 => uint256) public SequencingMethodPrice; //Mapping each sequecning method to its corresponding price

    // NFT count => struct 
    mapping(uint256 => RGDNFT) public RawNFTs; //Maps each RGDNFT to a unique number within the mgmt SC

    //NFT Count => sequence number
    mapping(uint256 => uint256) public SequencingRequestsCounter; //Stores the number of request and it keeps going up and cannot be changed manually

    //NFT count => mapping(request number => buyer address)
    mapping(uint256 => mapping(uint256 => address)) public SequenceRequesterAddress; //Stores the address of the buyer who requested sequencing

    
    //NFT count => (buyer address => request number)
    mapping(uint256 => mapping(address => uint256)) public SequencingRequestNumberPerBuyer; //The buyer address is necessary becauase new buyers might come after and mess up the counter

    //NFT count => active sequencing requests
    mapping(uint256 => uint256) public ActiveSequencingRequests; 

    //NFT count => active initial full access requests
    mapping(uint256 => uint256) public ActiveInitialFullAccessRequests;

    //buyer address => (NFT count => bool)
    mapping(address => mapping(uint256 => bool)) public sequencingPayerTracker; //Tracks the addresses of buyers who made sequencing payments for RAWNFTId (assuming same address cant make more than one payment to the same NFT at the same time)

    //NFT count => (Request number => sequencing method)
    mapping(uint256 => mapping(uint256 => uint256)) public RequestedSequencingMethod;
    

    //NFT count => (requestnumber => sequencing center address)
    mapping(uint256 => mapping(uint256 => address)) public CommittedsequencingCenter;

    //NFT Count => (request number => bool)
    mapping(uint256 => mapping(uint256 => bool)) public SequencingRequestNumberExist; //Checks if the sequencing request number exists or not


    //NFT count => (request number => bool)
    mapping(uint256 => mapping(uint256 => bool)) public SequencingRequestCompleted; //Checks if the sequencing request has been fulfilled or not (important to check before allowing the buyer to withdraw funds)


    //SGD token id => FAT address
    mapping(uint256 => address) public SGDToFATContract; //Maps the minted SGD NFT to its corresponding FAT SC



    //SGDNFT Variables//
    struct SGDNFT{
        uint256 SeqNFTId; //a counter within the SC only
        IERC721 nft2; //Necessary to enable transferring nfts when called later on
        address payable dataOwner; 
        uint256 tokenId; 
        uint256 fullaccessprice; //It is assumed that the price for full access is fixed but it can be decided in an auction if needed
        uint256 limitedaccessprice; //This is the price for one operation on the encrypted data
    }


    //NFT count => struct
    mapping(uint256 => SGDNFT) public SGDNFTs; //Maps each SGDNFT to a unique number within the mgmt SC

    //NFT count => active request numbers
    mapping(uint256 => uint256) public ActiveSGDNFTRequests;



    //NFT Composability Variables and Mappings//

    // SequencedNFTAddress => RawNFTAddress
    mapping(address => address) public childToParentAddress; //Maps the child address to the parent address

    //SequencedNFTAddress => (Child ID => Parent ID)
    mapping(address => mapping(uint256 => uint256)) public  childToParentTokenId; //Links each sequenced NFT to its parent RAW NFT token ID

    //ParentID => Child IDs
    mapping(uint256 => uint256[]) public tokenIDToParentTokenId; //Maps the token ID of parent to children token IDs

    //child ID => (parent ID => bool)
    mapping(uint256 => mapping(uint256 => bool)) public tokenIDToParentTokenIdCheck; //Checks if the provided token ID is a child to the parent ID


    //parent ID => actively listed children id 
    mapping(uint256 => uint256) public ActiveChildrenListings; //This mapping is needed to check if the owner has any active listings before delisting the parent token


    // NFT count => mapping(buyer address => bool)
    mapping(uint256 => mapping(address => bool)) public LimitedAccessBuyers; 

    //NFT count => mapping(buyer address => #operations)
    mapping(uint256 => mapping(address => uint256)) public LimitedAccessOperationsCounter; //Tracks the number of permitted limited access operations per buyer


    //**** Events ****//
    event ListedRGDNFT(uint256 RawNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner);
    event DelistedRGDNFT(uint256 RawNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner);
    event RGDNFTSequencingPayment(uint256 RawNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner, address indexed buyer, uint256 requestnumber, uint256 sequencingmethod, uint256 sequencingcost);
    event SequencingCenterCommitted(uint256 RawNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner, address indexed CommittedsequencingCenter);
    event RGDNFTSequenced(uint256 RawNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner, address buyer, address indexed sequencingCenter);
    event ListedSGDNFT(uint256 SeqNFTId, address indexed nft2 , uint256 tokenId, address indexed dataOwner, uint256 fullaccessprice, uint256 limitedaccessprice); 
    event DelistedSGDNFT(uint256 SeqNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner);
    event FullAccessGranted(uint256 SeqNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner, address indexed fullaccessbuyer);
    event LimitedAccessGranted(uint256 SeqNFTId, address indexed nft, uint256 tokenId, address indexed dataOwner, address indexed dataBuyer);



    constructor(uint256 _sequencingPrice1, uint256 _sequencingPrice2, uint256 _sequencingPrice3, address _rawNFTaddress, address _seqNFTAddress){
        
        SequencingMethodPrice[1] = _sequencingPrice1 * 1 wei;
        SequencingMethodPrice[2] = _sequencingPrice2 * 1 wei;
        SequencingMethodPrice[3] = _sequencingPrice3 * 1 wei;
        RegistrationAuthority = msg.sender; //The deployer of the smart contract is the registration authority
        RGDNFTSC = IERC721(_rawNFTaddress); //the smart contract address is casted in IERC721 to allow it to access its functionalities such as transfer
        SGDNFTSC = IERC721(_seqNFTAddress);
        SequencedGenomicDataNFT = ISequencedGenomicDataNFT(_seqNFTAddress);
        childToParentAddress[_seqNFTAddress] = _rawNFTaddress; //Indicates that the RAW NFT smart contract is the parent for Sequenced NFT address
    }


    

    //**** Modifiers ****//
    modifier onlySequencingCenter{
      require(sequencingCenter[msg.sender], "Only authorized sequence centers can run this function");
      _;
    }

    modifier onlyRegistrationAuthority{
        require(msg.sender == RegistrationAuthority, "Only the registration authority can run this function");
        _;
    }

    modifier onlySGDNFTSC{
        require(msg.sender == address(SGDNFTSC), "Only the the sequenced NFT smart contract can run this function");
        _;
    }

    modifier onlyLimitedAccessOracle{
        require(msg.sender == LimitedAccessOracle, "Only the LimitedAccessOracle can run this function");
        _;
    }





    //**** Functions ****//
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function RegisterSequencingCenter(address _sequencingCenter) external onlyRegistrationAuthority{
        sequencingCenter[_sequencingCenter] = true;
    }

    function RegisterLimitedAccessOracle(address _LimitedAccessOracle) external onlyRegistrationAuthority{
        LimitedAccessOracle = _LimitedAccessOracle;
    }


    function UpdateSequencingMethodPrice(uint256 _method1price, uint256 _method2price, uint256 _method3price) external onlySequencingCenter{
        SequencingMethodPrice[1] = _method1price * 1 wei;
        SequencingMethodPrice[2] = _method2price * 1 wei;
        SequencingMethodPrice[3] = _method3price * 1 wei;
    }

    //This function is used to return the max value among the sequencing methods prices [Note: The input is specified to 3 numbers because there are only 3 sequencing methods in our solution]
    function max(uint256[3] memory numbers) internal pure returns (uint256) {
    require(numbers.length > 0); // throw an exception if the condition is not met
    uint256 maxNumber; // default 0, the lowest value of `uint256`

    for (uint256 i = 0; i < numbers.length; i++) {
        if (numbers[i] > maxNumber) {
            maxNumber = numbers[i];
        }
    }

    return maxNumber;
}

    //This function only lists the RGD NFT so that an interested buyer can view it and decide to sequence it or not
    //This function won't work unless the user has an NFT with the specified token ID in the RGDNFTSC
    function listRGDNFT(uint256 _tokenId) external  nonReentrant{
        RGDNFTSC.transferFrom(msg.sender, address(this), _tokenId); //Transfers the NFT from its owner to the smart contract 
        RGDNFTCount++; 
        RawNFTs[RGDNFTCount] = RGDNFT (RGDNFTCount, RGDNFTSC, _tokenId, payable(msg.sender));
        
        emit ListedRGDNFT(RGDNFTCount, address(RGDNFTSC), _tokenId, msg.sender); 
    }

    function delistRGDNFT(uint256 _RawNFTId) external nonReentrant{
        RGDNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(msg.sender == Raw.dataOwner, "Only the owner of the Raw Genomic NFT is allowed to delist it");
        require(ActiveSequencingRequests[Raw.RawNFTId] == 0, "There are active sequencing requestes, therefore, it cannot be delisted");
        require(ActiveChildrenListings[Raw.RawNFTId] == 0, "The NFT cannot be delisted as it has active children NFTs listed");
        require(ActiveInitialFullAccessRequests[Raw.RawNFTId] == 0, "The NFT cannot be delisted as it has an active intial full access request");       
        delete RawNFTs[_RawNFTId]; //Removes all entries of the delisted NFT
        Raw.nft.transferFrom(address(this), Raw.dataOwner, Raw.tokenId);

        emit DelistedRGDNFT(Raw.RawNFTId, address(Raw.nft), Raw.tokenId, msg.sender);
    }

    //This function allows an interested buyer to pay for the sequencing of a raw genomic NFT and gain full access
    //The owner can decide to pay for sequencing 
    function PayForRawNFTSequencing(uint256 _sequencingmethod, uint256 _RawNFTId) external payable nonReentrant{
        RGDNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(_RawNFTId > 0 && _RawNFTId <= RGDNFTCount, "The requested NFT doesn't exist");
        require(SequencingMethodPrice[_sequencingmethod] > 0, "The selected sequencing method does not exist"); //If free sequencinng is required in the solution, then a mapping to boolean will be needed
        require(msg.value == SequencingMethodPrice[_sequencingmethod], "Not enough wei to cover the sequencing cost or it exceeds the sequencing cost");
        require(!sequencingPayerTracker[msg.sender][Raw.RawNFTId], "This buyer has already submitted a sequencing request for this NFT");

        payable(address(this)).call{value: SequencingMethodPrice[_sequencingmethod]}; //The sequencing value remains in the smart contract until the sequencing is completed 
        sequencingPayerTracker[msg.sender][Raw.RawNFTId] = true; //Tells if the msg.sender is an active sequencing payer or not
        SequencingRequestsCounter[Raw.RawNFTId] +=1; 
        SequencingRequestNumberPerBuyer[Raw.RawNFTId][msg.sender] = SequencingRequestsCounter[Raw.RawNFTId]; //Storing the request number per buyer
        ActiveSequencingRequests[Raw.RawNFTId] += 1; //The active number of requests can be updated when a request is fulfilled
        ActiveInitialFullAccessRequests[Raw.RawNFTId] += 1; //This is important to ensure the buyer receives the sequenced NFT from the buyer after the sequencing center finishes its task
        SequenceRequesterAddress[Raw.RawNFTId][SequencingRequestsCounter[Raw.RawNFTId]] = msg.sender; //Stores the address of sequence requester to be used for checking during message signature       
        RequestedSequencingMethod[Raw.RawNFTId][SequencingRequestNumberPerBuyer[Raw.RawNFTId][msg.sender]] = _sequencingmethod;
        SequencingRequestNumberExist[Raw.RawNFTId][SequencingRequestsCounter[Raw.RawNFTId]] = true; //This ensures that the sequence center selects a valid request number
        
    
        emit RGDNFTSequencingPayment(Raw.RawNFTId, address(Raw.nft), Raw.tokenId, Raw.dataOwner, msg.sender, SequencingRequestNumberPerBuyer[Raw.RawNFTId][msg.sender], _sequencingmethod, SequencingMethodPrice[_sequencingmethod]);

    }



    //This function allows sequencing centers to commit to a raw genomic data sequencing
    function CommitToSequencingRequest(uint256 _requestnumber, uint256 _RawNFTId) external onlySequencingCenter{
        RGDNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(_RawNFTId > 0 && _RawNFTId <= RGDNFTCount, "The requested NFT doesn't exist");
        require(!SequencingRequestCompleted[Raw.RawNFTId][_requestnumber], "This sequencing request has already been completed");
        require(SequencingRequestNumberExist[Raw.RawNFTId][_requestnumber], "Either the inserted request number or NFT ID is invalid");
        require(CommittedsequencingCenter[Raw.RawNFTId][_requestnumber] == address(0), "A sequencing center is already committed to sequencing this raw genomic data");

        CommittedsequencingCenter[Raw.RawNFTId][_requestnumber] = payable(msg.sender); //The sequencing center calling this function becomes accountable for this NFT
        
        emit SequencingCenterCommitted(Raw.RawNFTId, address(Raw.nft),  Raw.tokenId,  Raw.dataOwner, msg.sender);
    }


    //Note: The delivery of DNA sample and returning the sequenced genomic data can be traced on-chain, but they are outside the scope of our paper
    function ConfirmRGDNFTSequencing(string memory _tokenURI, uint256 _requestnumber, uint256 _RawNFTId) external nonReentrant onlySequencingCenter{
        
        RGDNFT storage Raw = RawNFTs[_RawNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(CommittedsequencingCenter[Raw.RawNFTId][_requestnumber] == msg.sender, "Only the committed sequencing center to this NFT can execute this function");

        payable(msg.sender).transfer(SequencingMethodPrice[RequestedSequencingMethod[Raw.RawNFTId][_requestnumber]]);
        ActiveSequencingRequests[Raw.RawNFTId] -= 1; 
        SequencingRequestCompleted[Raw.RawNFTId][_requestnumber] = true; 

        //Mint the SGD NFT for the owner
        uint SGDNFTID = SequencedGenomicDataNFT.mint(_tokenURI, _RawNFTId, Raw.dataOwner);

        //Deploying an ERC20 SC for the RGD owner to facilitate full access
        FullAccessToken newToken = new FullAccessToken("Full Access Token", "FAT");

        newToken.mint(SequenceRequesterAddress[Raw.RawNFTId][SequencingRequestsCounter[Raw.RawNFTId]], 1 * 10 ** 18);
        
        SGDToFATContract[SGDNFTID] = address(newToken); //A FAT contract is dedicated for this particular token [For other sequncing methods there should be another FAT, but for simplicity we will have only one]

        emit RGDNFTSequenced(Raw.RawNFTId, address(Raw.nft), Raw.tokenId, Raw.dataOwner, SequenceRequesterAddress[Raw.RawNFTId][_requestnumber], msg.sender);
    }



    //
    function LinkChildNFTtoParentNFT(uint256 _parentID, uint256 _childID) external onlySGDNFTSC{
        RGDNFT storage Raw = RawNFTs[_parentID]; //Stores all the related data of the requested genomic NFT to easily access it

        require(childToParentAddress[msg.sender] == address(RGDNFTSC), "Cannot link the new minted NFT as it is not a child of the parent NFT");
        
        childToParentTokenId[msg.sender][_childID] = Raw.tokenId; //Might not be needed
        tokenIDToParentTokenId[Raw.tokenId].push(_childID); //links the newly minted Child Id to its parent
        tokenIDToParentTokenIdCheck[_childID][Raw.tokenId] = true; //Used to verify that a certain child token ID actually belongs to a parent token ID(or the other way around)
    }




    //This function only lists the sequenced genomic NFT 
    //This function won't work unless the user has an NFT with the specified token ID in the SGDNFTSC
    function listSGDNFT(uint256 _tokenId, uint256 _fullaccessprice, uint256 _limitedaccessprice) external nonReentrant{
        SGDNFTSC.transferFrom(msg.sender, address(this), _tokenId); //Transfers the NFT from its owner to the smart contract until process is completed
        SGDNFTCount++; 
        SGDNFTs[SGDNFTCount] = SGDNFT(SGDNFTCount, SGDNFTSC, payable(msg.sender), _tokenId, (_fullaccessprice * 1 wei),( _limitedaccessprice * 1 wei)); //new address[](0) is used to initialize an empty array
        ActiveChildrenListings[childToParentTokenId[address(SGDNFTSC)][_tokenId]] += 1;
        emit ListedSGDNFT(SGDNFTCount, address(SGDNFTSC), _tokenId, msg.sender, _fullaccessprice, _limitedaccessprice); 
    }

    function delistSGDNFT(uint256 _SeqNFTId) external nonReentrant{
        SGDNFT storage Sequenced = SGDNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(msg.sender == Sequenced.dataOwner, "Only the owner of the sequenced Genomic NFT is allowed to delist it");
        require(ActiveSGDNFTRequests[Sequenced.SeqNFTId] == 0, "Cannot delist while there are pending full/limited access requests");
        ActiveChildrenListings[Sequenced.SeqNFTId] -= 1;
        delete SGDNFTs[Sequenced.SeqNFTId]; //Removes all entries of the delisted NFT
        Sequenced.nft2.transferFrom(address(this), msg.sender, Sequenced.tokenId);
        emit DelistedSGDNFT(Sequenced.SeqNFTId, address(Sequenced.nft2), Sequenced.tokenId, msg.sender);
    }

    function requestFullAccess(uint256 _SeqNFTId) external payable nonReentrant{
        SGDNFT storage Sequenced = SGDNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(_SeqNFTId > 0 && _SeqNFTId <= SGDNFTCount , "The requested NFT does not exist");
        require(msg.value == Sequenced.fullaccessprice, "Not enough wei to cover the cost of full access");
        require(msg.sender != Sequenced.dataOwner, "The NFT owner cannot execute this function");

        
        //IERC20(SGDToFATContract[_SeqNFTId]).transfer(msg.sender, 1 * 10 ** 18);

        FullAccessToken(SGDToFATContract[_SeqNFTId]).mint(msg.sender, 1 * 10 ** 18);
        payable(Sequenced.dataOwner).transfer(Sequenced.fullaccessprice);

        emit FullAccessGranted(Sequenced.SeqNFTId, address(Sequenced.nft2), Sequenced.tokenId, Sequenced.dataOwner, msg.sender);

    }


    //This function increases the number of operations the buyer is allowed to perform homomorphically on the encrypted genomic data
    //It is assumed that once the buyer pays for operations, he's allowed to perform operations homomorphically on the data immediatly, therefore, there is no need for ProofofLimitedAccess Function
    function requestLimitedAccess(uint256 _SeqNFTId, uint256 _numberofoperations) external payable nonReentrant{
        SGDNFT storage Sequenced = SGDNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        require(_SeqNFTId > 0 && _SeqNFTId <= SGDNFTCount , "The requested NFT does not exist");
        require(msg.value == _numberofoperations * Sequenced.limitedaccessprice, "Not enough wei to cover the cost of limited access");
        require(msg.sender != Sequenced.dataOwner, "The NFT owner cannot execute this function");

        LimitedAccessOperationsCounter[_SeqNFTId][msg.sender] +=  _numberofoperations; //The number of permitted operations for the msg.sender for this specific NFT (_SeqNFTId) is increased
        payable(Sequenced.dataOwner).transfer(_numberofoperations * Sequenced.limitedaccessprice); //The total value should be the requested number of operations * cost/operation

        emit LimitedAccessGranted(Sequenced.SeqNFTId, address(Sequenced.nft2), Sequenced.tokenId, Sequenced.dataOwner, msg.sender);
    }


    function UpdateBuyerLimitedAccessOperations(uint256 _SeqNFTId, uint256 _numberofexecutedoperations, address _dataBuyer) external onlyLimitedAccessOracle{
        SGDNFT storage Sequenced = SGDNFTs[_SeqNFTId]; //Stores all the related data of the requested genomic NFT to easily access it
        
        LimitedAccessOperationsCounter[Sequenced.SeqNFTId][_dataBuyer] -= _numberofexecutedoperations; // This updates the balance of operations for the limited access buyer

    }


}
