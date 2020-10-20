/*
 * Copyright (c) 2020 the original author or authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */
import {ComponentFixture, TestBed, waitForAsync} from '@angular/core/testing';

import {BreadcrumbsContainerComponent} from './breadcrumbs.container.component';
import {BreadcrumbsFacade} from "../breadcrumbs/breadcrumbs.facade";

describe('Breadcrumbs.ContainerComponent', () => {
  let component: BreadcrumbsContainerComponent;
  let fixture: ComponentFixture<BreadcrumbsContainerComponent>;

  beforeEach(waitForAsync(() => {
    TestBed.configureTestingModule({
      declarations: [BreadcrumbsContainerComponent],
      providers: [{provide: BreadcrumbsFacade, useValue: {}}]
    })
      .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(BreadcrumbsContainerComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeDefined();
  });
});
