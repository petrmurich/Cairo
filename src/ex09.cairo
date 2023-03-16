// ######## Ex 09
// # Recursions - advanced
// In this exercise, you need to:
// - Use this contract's claim_points() function
// - Your points are credited by the contract

#[contract]
mod Ex09 {
    use zeroable::Zeroable;
    use starknet::get_caller_address;
    use starknet::ContractAddressZeroable;
    use starknet::ContractAddressIntoFelt;
    use starknet::FeltTryIntoContractAddress;
    use starknet::contract_address_try_from_felt;
    use traits::Into;
    use traits::TryInto;
    use array::ArrayTrait;
    use option::OptionTrait;
    use integer::u256_from_felt;
    use hash::LegacyHash;
    use integer::u32_to_felt;

    // Internal Imports
    use starknet_cairo_101::utils::ex00_base::Ex00Base::tderc20_address;
    use starknet_cairo_101::utils::ex00_base::Ex00Base::has_validated_exercise;
    use starknet_cairo_101::utils::ex00_base::Ex00Base::distribute_points;
    use starknet_cairo_101::utils::ex00_base::Ex00Base::validate_exercise;
    use starknet_cairo_101::utils::ex00_base::Ex00Base::ex_initializer;

    ////////////////////////////////
    // Constructor
    ////////////////////////////////
    #[constructor]
    fn constructor(
        _tderc20_address: felt, _players_registry: felt, _workshop_id: felt, _exercise_id: felt
    ) {
        ex_initializer(_tderc20_address, _players_registry, _workshop_id, _exercise_id);
    }

    ////////////////////////////////
    // EXTERNAL FUNCTIONS
    ////////////////////////////////

    #[external]
    fn claim_points(array: Array::<felt>) {
        assert(!array.is_empty(), 'EMPTY_ARRAY');
        assert(u32_to_felt(array.len()) >= 4, 'ARRAY_LEN_LT_4');

        // Calculating the sum of the array sent by the user
        let mut sum: felt = 0;
        sum = get_sum_internal(sum, array);
        assert(sum >= 50, 'SUM_LT_50');

        // Reading caller address
        let sender_address: ContractAddress = get_caller_address();

        // Checking if the user has validated the exercise before
        validate_exercise(sender_address.into());
        // Sending points to the address specified as parameter
        distribute_points(sender_address.into(), u256_from_felt(2));
    }


    ////////////////////////////////
    // INTERNAL FUNCTIONS
    ////////////////////////////////
    fn get_sum_internal(mut sum: felt, mut values: Array::<felt>) -> felt {
        if !values.is_empty() {
            sum = sum + values.pop_front().unwrap();
            get_sum_internal(sum, values);
        }

        sum
    }
}