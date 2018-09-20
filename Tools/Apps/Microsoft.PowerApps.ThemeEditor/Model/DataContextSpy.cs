using System;
using System.ComponentModel;
using System.Windows;
using System.Windows.Data;

namespace PowerApps_Theme_Editor.Model
{
    public class DataContextSpy : Freezable
    {
        public DataContextSpy()
        {
            BindingOperations.SetBinding(this, DataContextProperty, new Binding());

            this.IsSynchronizedWithCurrentItem = true;
        }

        public bool IsSynchronizedWithCurrentItem { get; set; }

        public object DataContext
        {
            get { return (object)GetValue(DataContextProperty); }
            set { SetValue(DataContextProperty, value); }
        }

        public static readonly DependencyProperty DataContextProperty =
            FrameworkElement.DataContextProperty.AddOwner(
            typeof(DataContextSpy),
            new PropertyMetadata(null, null, OnCoerceDataContext));

        private static object OnCoerceDataContext(DependencyObject depObj, object value)
        {
            DataContextSpy spy = depObj as DataContextSpy;
            if (spy == null)
                return value;

            if (spy.IsSynchronizedWithCurrentItem)
            {
                ICollectionView view = CollectionViewSource.GetDefaultView(value);
                if (view != null)
                    return view.CurrentItem;
            }

            return value;
        }

        protected override Freezable CreateInstanceCore()
        {
            throw new NotImplementedException();
        }
    }
}