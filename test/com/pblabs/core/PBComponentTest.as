package com.pblabs.core
{
    import flash.display.Stage;

    import mockolate.runner.MockolateRule;

    import com.pblabs.pb_internal;

    import org.hamcrest.assertThat;
    import org.hamcrest.collection.hasItem;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.isFalse;
    import org.hamcrest.object.isTrue;
    import org.hamcrest.object.notNullValue;
    import org.hamcrest.object.nullValue;
    import org.hamcrest.object.strictlyEqualTo;

    use namespace pb_internal;

    public class PBComponentTest
    {
        private static const COMPONENT_NAME:String = "component";
        private static const BINDING_FIELD_NAME:String = "binding";
        private static const BINDING_PROPERTY_REFERENCE:String = "@component.binding";

        [Rule]
        public var mockRule:MockolateRule = new MockolateRule();

        private var component:PBComponent;

        [Before(async)]
        public function setup():void
        {
            component = new PBComponent();
        }

        [Test]
        public function PBComponent_constructed():void
        {
            assertThat(component, notNullValue());
        }

        [Test]
        public function name_canBeSet_valueEqualsInput():void
        {
            component.name = COMPONENT_NAME;

            assertThat(component.name, equalTo(COMPONENT_NAME));
        }

        [Test(expects="Error")]
        public function name_cannotBeSetIfOwned_throwsFault():void
        {
            component._owner = new PBGameObject();

            component.name = COMPONENT_NAME;
        }

        [Test]
        public function owner_canBeSet_valueEqualsInput():void
        {
            var owner:PBGameObject = new PBGameObject();

            component._owner = owner;

            assertThat(component._owner, strictlyEqualTo(owner));
        }

        [Test]
        public function addBinding_bindingIsAdded():void
        {
            var component:TestingComponent = new TestingComponent();
            component.addBinding(BINDING_FIELD_NAME, BINDING_PROPERTY_REFERENCE);

            assertThat(component.hasBinding(BINDING_FIELD_NAME, BINDING_PROPERTY_REFERENCE), isTrue());
        }

        [Test]
        public function addBinding_bindingsVectorIsCreatedIfNull():void
        {
            var component:TestingComponent = new TestingComponent();
            component.addBinding(BINDING_FIELD_NAME, BINDING_PROPERTY_REFERENCE);

            assertThat(component.getBindings(), notNullValue());
        }

        [Test]
        public function removeBinding_noBindingsRemovedIfThereAreNoBindings_returnsFalse():void
        {
            var component:TestingComponent = new TestingComponent();

            var wasRemoved:Boolean = component.removeBinding(BINDING_FIELD_NAME, BINDING_PROPERTY_REFERENCE);

            assertThat(wasRemoved, isFalse());
        }

        [Test]
        public function removeBinding_noBindingRemovedIfBindingNotAdded_returnsFalse():void
        {
            var component:TestingComponent = new TestingComponent();
            component.addBinding("otherBinding", "@component.otherBinding");

            var wasRemoved:Boolean = component.removeBinding(BINDING_FIELD_NAME, BINDING_PROPERTY_REFERENCE);

            assertThat(wasRemoved, isFalse());
        }

        [Test]
        public function removeBinding_bindingRemovedIfAdded_returnsTrue():void
        {
            var component:TestingComponent = new TestingComponent();
            component.addBinding(BINDING_FIELD_NAME, BINDING_PROPERTY_REFERENCE);

            var wasRemoved:Boolean = component.removeBinding(BINDING_FIELD_NAME, BINDING_PROPERTY_REFERENCE);

            assertThat(wasRemoved, isTrue());
        }

        [Test]
        public function hasBinding_ifBindingAdded_returnsTrue():void
        {
            var component:TestingComponent = new TestingComponent();
            component.addBinding(BINDING_FIELD_NAME, BINDING_PROPERTY_REFERENCE);

            assertThat(component.hasBinding(BINDING_FIELD_NAME, BINDING_PROPERTY_REFERENCE), isTrue());
        }

        [Test(expects="Error")]
        public function applyBindings_noPropertyManager_throwsError():void
        {
            component.addBinding(BINDING_FIELD_NAME, BINDING_PROPERTY_REFERENCE);

            component.applyBindings();
        }

        [Test]
        public function applyBindings_bindingAppliedWithManager():void
        {
            var manager:MockPropertyManager = new MockPropertyManager();
            component.propertyManager = manager;
            component.addBinding(BINDING_FIELD_NAME, BINDING_PROPERTY_REFERENCE);

            component.applyBindings();

            assertThat(manager.bindingApplied(BINDING_FIELD_NAME, BINDING_PROPERTY_REFERENCE), isTrue());
        }

        [Test(expects="Error")]
        public function doAdd_failsIfSuperIsNotCalled_throwError():void
        {
            var component:FailComponent = new FailComponent();

            component.doAdd();
        }

        [Test]
        public function doAdd_addsComponentThroughOnAdd_addedIsTrue():void
        {
            var component:TestingComponent = new TestingComponent();

            component.doAdd();

            assertThat(component.added, isTrue());
        }

        [Test(expected="Error")]
        public function doRemove_failsIfSuperIsNotCalled_throwsError():void
        {
            var component:FailComponent = new FailComponent();

            component.doRemove();
        }

        [Test]
        public function doRemove_removesComponentThroughOnRemove_removedIsTrue():void
        {
            var component:TestingComponent = new TestingComponent();

            component.doRemove();

            assertThat(component.removed, isTrue());
        }

        [Test]
        public function doRemove_setsOwnerToNull():void
        {
            var gameObject:PBGameObject = new PBGameObject();
            gameObject.addComponent(component, COMPONENT_NAME);

            component.doRemove();

            assertThat(component.owner, nullValue());
        }
    }
}

import com.pblabs.core.PBComponent;
import com.pblabs.core.PBGroup;

internal class TestingComponent extends PBComponent
{
    public var binding:MockBindingObject;

    public var added:Boolean;

    public var removed:Boolean;

    public function getBindings():Vector.<String>
    {
        return bindings;
    }

    override protected function onAdd():void
    {
        super.onAdd();

        added = true;
    }

    override protected function onRemove():void
    {
        super.onRemove();

        removed = true;
    }
}

internal class FailComponent extends PBComponent
{
    override protected function onAdd():void
    {
        //pass and don't call super for major FAIL
    }

    override protected function onRemove():void
    {
        //pass and don't call super for major FAIL
    }
}

import com.pblabs.property.PropertyManager;

internal class MockBindingObject
{
    public var bindingApplied:Boolean;
}

internal class MockPropertyManager extends PropertyManager
{
    public var appliedBindings:Array = [];

    public function bindingApplied(fieldName:String, propertyReference:String):Boolean
    {
        return appliedBindings.indexOf(fieldName + "||" + propertyReference) > -1;
    }

    override public function applyBinding(scope:*, binding:String):void
    {
        appliedBindings.push(binding);
    }
}

