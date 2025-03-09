import mysql.connector
from datetime import datetime
import json

class MemoryManager:
    def __init__(self, host="localhost", user="your_username", password="your_password", database="ai_memory_system"):
        self.db = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database
        )
        self.cursor = self.db.cursor()

    def store_short_term_memory(self, context_data, importance_score=0.5):
        """Store new information in short-term memory"""
        query = """
        INSERT INTO short_term_memory (context_data, importance_score)
        VALUES (%s, %s)
        """
        self.cursor.execute(query, (json.dumps(context_data), importance_score))
        self.db.commit()

    def retrieve_memories(self, query_context, memory_type="both", limit=5):
        """Retrieve relevant memories based on context"""
        if memory_type == "both":
            query = """
            (SELECT context_data, importance_score, 'short_term' as source
            FROM short_term_memory
            WHERE context_data LIKE %s
            ORDER BY importance_score DESC
            LIMIT %s)
            UNION
            (SELECT context_data, importance_score, 'long_term' as source
            FROM long_term_memory
            WHERE context_data LIKE %s
            ORDER BY importance_score DESC
            LIMIT %s)
            """
            self.cursor.execute(query, (f"%{query_context}%", limit, f"%{query_context}%", limit))
        else:
            table = "short_term_memory" if memory_type == "short" else "long_term_memory"
            query = f"""
            SELECT context_data, importance_score
            FROM {table}
            WHERE context_data LIKE %s
            ORDER BY importance_score DESC
            LIMIT %s
            """
            self.cursor.execute(query, (f"%{query_context}%", limit))

        results = self.cursor.fetchall()
        return [json.loads(row[0]) for row in results]

    def update_importance(self, memory_id, new_score, memory_type="short"):
        """Update importance score of a memory"""
        table = "short_term_memory" if memory_type == "short" else "long_term_memory"
        query = f"""
        UPDATE {table}
        SET importance_score = %s, access_count = access_count + 1, last_accessed = CURRENT_TIMESTAMP
        WHERE id = %s
        """
        self.cursor.execute(query, (new_score, memory_id))
        self.db.commit()

    def circulate_memories(self):
        """Trigger the memory circulation procedure"""
        self.cursor.execute("CALL circulate_memory()")
        self.db.commit()

    def __del__(self):
        """Clean up database connection"""
        self.cursor.close()
        self.db.close()

# Example usage:
def main():
    memory_manager = MemoryManager()
    
    # Store new information
    memory_manager.store_short_term_memory(
        {"content": "This is important information", "context": "example"},
        importance_score=0.8
    )

    # Retrieve relevant memories
    memories = memory_manager.retrieve_memories("important")
    
    # Circulate memories (should be called periodically)
    memory_manager.circulate_memories()

if __name__ == "__main__":
    main()