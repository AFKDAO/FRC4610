pub contract FRC4610 {

    pub var name: String
    pub var symbol: String

    pub resource interface NFTDelegateManager {

        pub fun setDelegator(newDelegator: Address)

        pub fun delegatorOf(): Address
    }

    pub resource NFT: NFTDelegateManager {
        pub var id: UInt64
        pub var delegator: Address

        pub fun setDelegator(newDelegator: Address) {
            self.delegator = newDelegator
        }

        pub fun delegatorOf(): Address {
            return self.delegator
        }

        // Initialize both fields in the init function
        init(initID: UInt64) {
            self.id = initID
            self.delegator = 0x0
        }
    }

    pub resource interface NFTReceiver {

        pub fun deposit(token: @NFT)

        pub fun getIDs(): [UInt64]

        pub fun idExists(id: UInt64): Bool

    }

    pub resource Collection: NFTReceiver {

        pub var ownedNFTs: @{UInt64: NFT}

        init () {
            self.ownedNFTs <- {}
        }

        pub fun withdraw(withdrawID: UInt64): @NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID)!

            return <-token
        }

        pub fun deposit(token: @NFT) {
            self.ownedNFTs[token.id] <-! token
        }

        pub fun idExists(id: UInt64): Bool {
            return self.ownedNFTs[id] != nil
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    pub resource NFTMinter {

        pub var idCount: UInt64

        init() {
            self.idCount = 1
        }

        pub fun mintNFT(): @NFT {
            var newNFT <- create NFT(initID: self.idCount)
            self.idCount = self.idCount + 1
            return <-newNFT
        }
    }

	  init() {
        self.name = "FRC4610"
        self.symbol = "FRC4610"

        self.account.save(<-self.createEmptyCollection(), to: /storage/NFTCollection)

        self.account.link<&{NFTReceiver}>(/public/NFTReceiver, target: /storage/NFTCollection)

        self.account.save(<-create NFTMinter(), to: /storage/NFTMinter)
    } 
}