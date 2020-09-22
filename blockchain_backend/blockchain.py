# To do: 1. Reward miners
import hashlib
import json

# these two can be used to reduce the memory size of the blockchain and files storing it
# import pickle
# import sqlite3

# import block class
from block import Block
from transaction import Transaction
from utility.verification import Verification
from utility.hash_util import hash_block
from wallet import Wallet


class Blockchain:

    def __init__(self, hosting_node_id):
        # Genesis block
        genesis_block = Block(0, '', [], 100, 0)
        # Empty blockchain
        self.__chain = [genesis_block]
        self.__open_transactions = []
        self.load_data()
        self.hosting_node = hosting_node_id

        # We will Store patient details in the blockchain
        # work on transaction validity

        # conn = sqlite3.connect('blockchain.db')
        # cursor = conn.cursor()

        # def createtable():
        #     cursor.execute(
        #         "CREATE TABLE IF NOT EXISTS blockchainstore(item Text,quantity Text)")
        #     conn.commit()

    def get_chain(self):
        return self.__chain[:]

    def get_open_transactions(self):
        return self.__open_transactions[:]

    def load_data(self):
        # load data from the txt file
        try:
            with open('data/blockchain.json', mode='r') as f:
                file_content = json.load(f)
                # we escape the \n using range
                blockchain = file_content["blockchain"]
                open_transactions = file_content["opentransactions"]

                # ordered dicts aid in using odering to calculate the guess in valid proof
                updated_blockchain = []

                for block in blockchain:
                    converted_transaction = [Transaction(
                        tx['sender'],
                        tx['receiver'],
                        tx['signature'],
                        tx['details'],
                    ) for tx in block['transactions']]

                    updated_block = Block(
                        block['index'],
                        block['previous_hash'],
                        converted_transaction,
                        block['proof'],
                        block['timestamp'],
                    )
                    updated_blockchain.append(updated_block)
                self.__chain = updated_blockchain

                updated_transactions = []
                for tx in open_transactions:
                    updated_transaction = Transaction(
                        tx['sender'],
                        tx['receiver'],
                        tx['signature'],
                        tx['details'],
                    )
                    updated_transactions.append(updated_transaction)
                self.__open_transactions = updated_transactions
        except (IOError, IndexError):
            pass

    def save_data(self):
        # createtable()
        # cursor.execute("INSERT INTO blockchainstore VALUES(?,?)", (str(blockchain), str(open_transactions)))
        # conn.commit()
        try:

            with open('data/blockchain.json', mode='w') as f:
                data = {}
                data["blockchain"]=[]
                data["opentransactions"]=[]
                saveable_chain = [block.__dict__ for block in [
                    # convert transactions to transaction object that can be json dumped
                    Block(
                        bl.index,
                        bl.previous_hash,
                        [tx.__dict__ for tx in bl.transactions],
                        bl.proof,
                        bl.timestamp
                    )for bl in self.__chain]]
                # f.write(json.dumps(saveable_chain))
                saveable_tx = [tx.__dict__ for tx in self.__open_transactions]
                # f.write(json.dumps(saveable_tx))

                data["blockchain"]=saveable_chain
                data["opentransactions"]=saveable_tx
                print(data["blockchain"])
                json.dump(data, f)
        except IOError:
            print('Saving Failed'+IOError.message)

    def proof_of_work(self):
        #  proof of work algorithm
        last_block = self.__chain[-1]
        last_hash = hash_block(last_block)
        proof = 0
        while not Verification.valid_proof(self.__open_transactions, last_hash, proof):
            proof += 1
        return proof

    def last_blockchain_value(self):
        """ Returns the last value of the current blockchain. """
        if len(self.__chain) < 1:
            return None
        return self.__chain[-1]

    def add_transaction(self, receiver, sender, signature, details):
        """ Append a new value as well as the last blockchain value to the blockchain.

            Arguments:
                sender:     Sender of the details.
                receiver:  Recepient of the details.
                signature:  Signature of the transaction
                details:    Details to be sent with the transaction.
        """
        if self.hosting_node == None:
            return False
        transaction = Transaction(sender, receiver, signature, details)
        print(transaction)
        if not Wallet.verify_transaction(transaction):
            return False
        self.__open_transactions.append(transaction)
        self.save_data()
        return True

    def mine_block(self):
        if self.hosting_node == None:
            return None
        if len(self.__open_transactions) <= 0:
            return 0
        last_block = self.__chain[-1]
        hashed_block = hash_block(last_block)
        proof = self.proof_of_work()

        # mined_details = {
        #     'visit_date': time,
        #     'mining_points': Gold_points,
        # }

        # mined_transaction = Transaction('MINING', self.hosting_node, ,'', mined_details)
        # copied_tx = self.__open_transactions[:]
        # copied_tx.append(mined_transaction)

        # #alternatively append open transactions instead of copied_tx

        block = Block(
            len(self.__chain),
            hashed_block,
            self.__open_transactions,
            proof
        )
        for tx in block.transactions:
            if not Wallet.verify_transaction(tx):
                return None

        self.__chain.append(block)
        self.__open_transactions = []
        self.save_data()
        return block

    def __repr__(self):
        return str(self.__dict__)