package com.pblabs.core
{
    import com.pblabs.property.PropertyManager;

    import org.hamcrest.assertThat;
    import org.hamcrest.collection.hasItems;
    import org.hamcrest.object.*;

    public class PBGameObjectTest
    {
        private static const GAME_OBJECT_NAME:String = "gameObject";
        private static const COMPONENT_NAME:String = "component";

        private var gameObject:PBGameObject;

        [Before]
        public function setup():void
        {
            gameObject = new PBGameObject( GAME_OBJECT_NAME );
            gameObject.owningGroup = new MockGroup();
        }

        [Test]
        public function PBGameObject_constructed():void
        {
            assertThat(gameObject, notNullValue());
        }

        [Test]
        public function name_whenConstructedWithNameParameter_nameEqualsParameter():void
        {
            assertThat(gameObject.name, equalTo(GAME_OBJECT_NAME));
        }

        [Test]
        public function deferring_whenSetToTrue_isTrue():void
        {
            gameObject.deferring = true;

            assertThat(gameObject.deferring, isTrue());
        }

        [Test]
        public function deferring_whenSetToFalse_isFalse():void
        {
            gameObject.deferring = false;

            assertThat(gameObject.deferring, isFalse());
        }

        [Test]
        public function deferring_initializesDeferredComponentsWhenSetFalse_componentsInitializedIsTrue():void
        {
            var component:MockComponent = new MockComponent();
            gameObject.deferring = true;
            gameObject.addComponent(component, COMPONENT_NAME);

            gameObject.deferring = false;

            assertThat(component.initialized, isTrue());
        }

        [Test]
        public function deferring_deferredComponentKeyRemovedWhenSetFalse_componentKeyReturnsNull():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            gameObject.owningGroup = new MockGroup();
            gameObject.deferring = true;
            gameObject.addComponent(component, COMPONENT_NAME);

            gameObject.deferring = false;

            assertThat(gameObject.components["!" + component.name], nullValue());
        }

        [Test]
        public function deferring_multipleComponentsInitializedWhenSetFalse_allComponentsInitialized():void
        {
            var component1:MockComponent = new MockComponent();
            var component2:MockComponent = new MockComponent();
            gameObject.deferring = true;
            gameObject.addComponent(component1, COMPONENT_NAME);
            gameObject.addComponent(component2, COMPONENT_NAME + 2);

            gameObject.deferring = false;

            assertThat(component1.initialized, isTrue());
            assertThat(component2.initialized, isTrue());
        }

        [Test(expects="Error")]
        public function addComponent_whenCalledWithNoComponentName_throwsError():void
        {
            var component:MockComponent = new MockComponent();

            gameObject.addComponent(component);
        }

        [Test]
        public function addComponent_setsComponentNameToNameArgument_nameIsEqualToArgument():void
        {
            var component:MockComponent = new MockComponent();

            gameObject.addComponent(component, COMPONENT_NAME);

            assertThat(component.name, equalTo(COMPONENT_NAME));
        }

        [Test]
        public function addComponent_initializesComponentWhenCalledWithNameArgument_initializedIsTrue():void
        {
            var component:MockComponent = new MockComponent();
            gameObject.deferring = false;

            gameObject.addComponent(component, COMPONENT_NAME);

            assertThat(component.initialized, isTrue());
        }

        [Test]
        public function addComponent_namedComponentInitializedWithoutNameArgument_initializedIsTrue():void
        {
            var component:MockComponent = new MockComponent();
            component.name = COMPONENT_NAME;
            gameObject.deferring = false;

            gameObject.addComponent(component);

            assertThat(component.initialized, isTrue());
        }

        [Test]
        public function addComponent_componentOwnerIsSet_ownerEqualsGroup():void
        {
            var component:MockComponent = new MockComponent();
            component.name = COMPONENT_NAME;
            gameObject.deferring = false;

            gameObject.addComponent(component);

            assertThat(component.owner, strictlyEqualTo(gameObject));
        }

        [Test]
        public function addComponent_gameObjectNamedPropertyIsSet_namedPropertyValueEqualsComponent():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            component.name = COMPONENT_NAME;

            gameObject.addComponent(component);

            assertThat(gameObject[COMPONENT_NAME], strictlyEqualTo(component));
        }

        [Test]
        public function addComponent_whenDeferring_componentStoredMarkedAsDeferred():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            component.name = COMPONENT_NAME;
            gameObject.deferring = true;

            gameObject.addComponent(component);

            assertThat(gameObject.components["!" + COMPONENT_NAME], strictlyEqualTo(component));
        }

        [Test]
        public function addComponent_whenDeferring_componentIsNotInitialized():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            component.name = COMPONENT_NAME;
            gameObject.deferring = true;

            gameObject.addComponent(component);

            assertThat(component.initialized, isFalse());
        }

        [Test]
        public function removeComponent_ownedByGameObject_removedIsTrue():void
        {
            var component:MockComponent = new MockComponent();
            gameObject.deferring = false;
            gameObject.addComponent(component, COMPONENT_NAME);

            gameObject.removeComponent(component);

            assertThat(component.removed, isTrue());
        }

        [Test(expects="Error")]
        public function removeComponent_notOwnedByGameObject_throwsError():void
        {
            var component:MockComponent = new MockComponent();

            gameObject.removeComponent(component);
        }

        [Test]
        public function removeComponent_removesNamedComponentProperty_propertyIsNull():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            gameObject.owningGroup = new MockGroup();
            gameObject.deferring = false;
            gameObject.addComponent(component, COMPONENT_NAME);

            gameObject.removeComponent(component);

            assertThat(gameObject[COMPONENT_NAME], nullValue());
        }

        [Test]
        public function removeComponent_removesComponentFromDictionary_componentKeyIsNull():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            gameObject.owningGroup = new MockGroup();
            gameObject.deferring = false;
            gameObject.addComponent(component, COMPONENT_NAME);

            gameObject.removeComponent(component);

            assertThat(gameObject.components[COMPONENT_NAME], nullValue());
        }

        [Test]
        public function lookupComponent_providedWithComponentName_componentIsEqualTo():void
        {
            var component:MockComponent = new MockComponent();
            var lookup:PBComponent;
            gameObject.deferring = false;
            gameObject.addComponent(component, COMPONENT_NAME);

            lookup = gameObject.lookupComponent(COMPONENT_NAME);

            assertThat(lookup, strictlyEqualTo(component));
        }

        [Test]
        public function getAllComponents_returnsAddedComponents():void
        {
            var component1:MockComponent = new MockComponent();
            var component2:MockComponent = new MockComponent();
            var components:Vector.<PBComponent>;

            gameObject.addComponent(component1, COMPONENT_NAME);
            gameObject.addComponent(component2, COMPONENT_NAME + 2);

            components = gameObject.getAllComponents();

            assertThat(components, hasItems(component1, component2));
        }

        [Test]
        public function initialize_addComponentsIfItIsProperty_addedIsTrue():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            gameObject.owningGroup = new MockGroup();

            gameObject.component = component;
            gameObject.initialize();

            assertThat(component.added, isTrue());
        }

        [Test]
        public function initialize_addedComponentIsNamedForProperty_namesAreEqual():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            gameObject.owningGroup = new MockGroup();

            gameObject.component = component;
            gameObject.initialize();

            assertThat(component.name, equalTo(COMPONENT_NAME));
        }

        [Test]
        public function initialize_doNotAddComponentPropertyIfAlreadyOwned_addedIsFalse():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            var owningGameObject:MockGameObject = new MockGameObject();
            gameObject.owningGroup = new MockGroup();
            owningGameObject.owningGroup = new MockGroup();

            owningGameObject.addComponent(component, COMPONENT_NAME);
            gameObject.component = component;
            gameObject.initialize();

            assertThat(component.added, isFalse());
        }

        [Test]
        public function initialize_owningGroupInjectsInto_injectedIntoTrue():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            gameObject.owningGroup = new MockGroup();

            gameObject.component = component;
            gameObject.initialize();

            assertThat(gameObject.injectedInto, isTrue());
        }

        [Test]
        public function initialize_deferringIsFalseAfterInitializing_deferringIsFalse():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            gameObject.owningGroup = new MockGroup();

            gameObject.component = component;
            gameObject.initialize();

            assertThat(gameObject.deferring, isFalse());
        }

        [Test]
        public function initialize_componentBindingsAreApplied_bindingAppliedIsTrue():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            gameObject.owningGroup = new MockGroup();

            gameObject.component = component;
            gameObject.initialize();

            assertThat(component.bindingsApplied, isTrue());
        }

        [Test]
        public function destroy_removesComponents_removedIsTrue():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            gameObject.owningGroup = new MockGroup();
            gameObject.deferring = false;
            gameObject.addComponent(component, COMPONENT_NAME);

            gameObject.destroy();

            assertThat(component.removed, isTrue());
        }

        [Test]
        public function setProperty_managerSetPropertyIsCalled_setPropertyCalledIsTrue():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            var propertyManager:MockPropertyManager = new MockPropertyManager();
            gameObject.owningGroup = new MockGroup();
            gameObject.owningGroup.registerManager(PropertyManager, propertyManager);

            gameObject.setProperty("@component.someProperty", "test");

            assertThat(propertyManager.setPropertyCalled, isTrue());
        }

        [Test]
        public function getProperty_managerGetPropertyIsCalled_getPropertyCalledIsTrue():void
        {
            var component:MockComponent = new MockComponent();
            var gameObject:MockGameObject = new MockGameObject();
            var propertyManager:MockPropertyManager = new MockPropertyManager();
            gameObject.owningGroup = new MockGroup();
            gameObject.owningGroup.registerManager(PropertyManager, propertyManager);

            gameObject.getProperty("@component.someProperty", "test");

            assertThat(propertyManager.getPropertyCalled, isTrue());
        }

    }
}

import com.pblabs.core.PBGameObject;
import com.pblabs.property.PropertyManager;

import flash.utils.Dictionary;

import mx.resources.ResourceManager;

internal class MockGameObject extends PBGameObject
{
    public var component:Object;

    public var injectedInto:Boolean;

    public function get components():Dictionary
    {
        return _components;
    }

    public function MockGameObject()
    {
        super("gameObject");
    }
}

import com.pblabs.core.PBComponent;
import com.pblabs.core.PBGroup;
import com.pblabs.pb_internal;

use namespace pb_internal

internal class MockComponent extends PBComponent
{
    public var added:Boolean;

    public var removed:Boolean;

    public var bindingsApplied:Boolean;


    public function MockComponent()
    {
        propertyManager = new MockPropertyManager();
    }

    public function get initialized():Boolean
    {
        return owner && added;
    }

    override pb_internal function doAdd():void
    {
        added = true;
    }

    override pb_internal function doRemove():void
    {
        super.doRemove();
        removed = true;
    }

    override public function applyBindings():void
    {
        bindingsApplied = true;
    }
}

/**
 * Mock class to break the dependency on the Injector for testing
 */
internal class MockGroup extends PBGroup
{
    public var objectsInjectedInto:Array = [];

    override public function injectInto(object:*):void
    {
        objectsInjectedInto.push(object);

        if(object is MockGameObject)
            MockGameObject(object).injectedInto = true;
    }
}

internal class MockPropertyManager extends PropertyManager
{
    public var setPropertyCalled:Boolean;
    public var getPropertyCalled:Boolean;

    override public function setProperty(scope:*, property:String, value:*):void
    {
        setPropertyCalled = true;
    }

    override public function getProperty(scope:*, property:String, defaultValue:*):*
    {
        getPropertyCalled = true;
    }
}