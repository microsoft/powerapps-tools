using Newtonsoft.Json;
using System.Collections.Generic;
using System.Linq;

namespace PowerApps_Theme_Editor.Model
{
    public class History<T>
    {
        private T original;
        private List<T> history;
        private int index;

        public History(T element)
        {
            original = this.copy(element);
            rest();
        }

        public void rest()
        {
            this.history = new List<T>();
            index = -1;
        }

        public T copy(T obj)
        {
            return JsonConvert.DeserializeObject<T>(JsonConvert.SerializeObject(obj));
        }

        public void execute(T element)
        {
            if (redo_available())
                this.history.RemoveRange(index + 1, this.history.Count - index - 1);
            else
                index = this.history.Count - 1;
            this.history.Add(this.copy(element));
            index++;
        }

        public T undo()
        {
            if (undo_available())
            {
                return copy(history.ElementAt(--index));
            }
            return original;
        }

        public T redo()
        {
            if (redo_available())
            {
                return copy(history.ElementAt(++index));
            }
            return original;
        }

        public bool undo_available()
        {
            return !(index < 1);
        }

        public bool redo_available()
        {
            return (index < history.Count() - 1);
        }

        public List<T> peek()
        {
            return history;
        }
    }
}