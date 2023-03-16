// ######## Ex 00
// # A contract from which other contracts can import functions

#[contract]
mod Ex00Base {
    // Core Library Imports
    use starknet::get_caller_address;
    use starknet::contract_address_to_felt;
    use integer::u256_from_felt;
    use zeroable::Zeroable;
    use starknet::ContractAddressZeroable;
    use starknet::ContractAddressIntoFelt;
    use starknet::FeltTryIntoContractAddress;
    use starknet::contract_address_try_from_felt;
    use traits::Into;
    use traits::TryInto;
    use array::ArrayTrait;
    use option::OptionTrait;

    // Internal Imports
    use starknet_cairo_101::utils::Iplayers_registry::Iplayers_registryDispatcherTrait;
    use starknet_cairo_101::utils::Iplayers_registry::Iplayers_registryDispatcher;
    use starknet_cairo_101::token::ITDERC20::ITDERC20DispatcherTrait;
    use starknet_cairo_101::token::ITDERC20::ITDERC20Dispatcher;


    ////////////////////////////////
    // STORAGE
    ////////////////////////////////
    struct Storage {
        tderc20_address_storage: ContractAddress,
        players_registry_storage: ContractAddress,
        workshop_id_storage: felt,
        exercise_id_storage: felt,
    }

    ////////////////////////////////
    // View Functions
    ////////////////////////////////
    #[view]
    fn tderc20_address() -> ContractAddress {
        tderc20_address_storage::read()
    }

    #[view]
    fn players_registry() -> ContractAddress {
        players_registry_storage::read()
    }

    #[view]
    fn workshop_id() -> felt {
        workshop_id_storage::read()
    }

    #[view]
    fn exercise_id() -> felt {
        exercise_id_storage::read()
    }

    #[view]
    fn has_validated_exercise(account: ContractAddress) -> bool {
        // reading player registry
        let players_registry = players_registry_storage::read();
        let workshop_id = workshop_id_storage::read();
        let exercise_id = exercise_id_storage::read();

        Iplayers_registryDispatcher{contract_address: players_registry}
            .has_validated_exercise(account, workshop_id, exercise_id)
    }

    ////////////////////////////////
    // Internal Constructor
    ////////////////////////////////
    fn ex_initializer(
        _tderc20_address: ContractAddress, _players_registry: ContractAddress, _workshop_id: felt, _exercise_id: felt
    ) {
        tderc20_address_storage::write(_tderc20_address);
        players_registry_storage::write(_players_registry);
        workshop_id_storage::write(_workshop_id);
        exercise_id_storage::write(_exercise_id);
    }

    ////////////////////////////////
    // Internal Functions
    ////////////////////////////////
    fn distribute_points(to: ContractAddress, amount: u256) {
        // Retrieving contract address from storage
        let tderc20_address = tderc20_address_storage::read();

        ITDERC20Dispatcher{contract_address: tderc20_address}
            .distribute_points(to, amount);
    }

    fn validate_exercise(account: ContractAddress) {
        // reading player registry
        let players_registry = players_registry_storage::read();
        let workshop_id = workshop_id_storage::read();
        let exercise_id = exercise_id_storage::read();

        let has_current_user_validated_exercise =
            Iplayers_registryDispatcher{contract_address: players_registry}
            .has_validated_exercise(account, workshop_id, exercise_id);

        assert(has_current_user_validated_exercise == false, 'Exercise previously validated');
        Iplayers_registryDispatcher{contract_address: players_registry}
            .validate_exercise(account, workshop_id, exercise_id);
    }
}