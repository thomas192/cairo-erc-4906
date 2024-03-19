// SPDX-License-Identifier: MIT

#[starknet::interface]
trait IERC4906<TContractState> {
    fn setBaseTokenURI(ref self: TContractState, tokenURI: ByteArray);
    fn emitBatchMetadataUpdate(ref self: TContractState, fromTokenId: u256, toTokenId: u256);
}

#[starknet::component]
pub mod ERC4906Component {
    use starknet::ContractAddress;
    use openzeppelin::token::erc721::ERC721Component;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    pub enum Event {
        MetadataUpdate: MetadataUpdate,
        BatchMetadataUpdate: BatchMetadataUpdate,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    struct MetadataUpdate {
        #[key]
        tokenURI: ByteArray,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    struct BatchMetadataUpdate {
        #[key]
        fromTokenId: u256,
        #[key]
        toTokenId: u256,
    }

    #[embeddable_as(ERC4906Impl)]
    impl ERC4906<
        TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>
    > of super::IERC4906<ComponentState<TContractState>> {
        fn setBaseTokenURI(ref self: ComponentState<TContractState>, tokenURI: ByteArray) {
            let mut erc721_comp = get_dep_component_mut!(ref self, ERC721);
            let newTokenURI = tokenURI.clone();

            // Write the new base token URI
            erc721_comp.ERC721_base_uri.write(tokenURI);

            // Emit event after base metadata is updated
            self.emit(MetadataUpdate { tokenURI: newTokenURI });
        }

        fn emitBatchMetadataUpdate(
            ref self: ComponentState<TContractState>, fromTokenId: u256, toTokenId: u256
        ) {
            // Emit event after metadata of a batch of tokens is updated
            self.emit(BatchMetadataUpdate { fromTokenId: fromTokenId, toTokenId: toTokenId });
        }
    }
}

